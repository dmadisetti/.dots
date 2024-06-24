#!/usr/bin/env python

# Massive hack, but moves over zotero pdfs into my notes systems with some
# metadate

import curses

from os import path, environ
from glob import glob
import shutil
import re
import os

from pybtex import database as btex

# Could try to combine zotero interfaces but whatever
# For general use
from pyzotero import zotero
# Specifically to sync indices
from zotero_cli.backend import ZoteroBackend

import time

if "ZOTERO_KEY" not in environ or "ZOTERO_USER" not in environ:
  raise Exception(
      "Please provide Zotero key and user (ZOTERO_KEY, ZOTERO_USER "
      "rpsct.) Preferably by creating your own zotero.gpg which "
      "just has this information encrypted, or as environmental "
      "vars (less ideal, but whatever).")
zot = zotero.Zotero(int(environ["ZOTERO_USER"]), "user", environ["ZOTERO_KEY"])
zotcli = ZoteroBackend(environ["ZOTERO_KEY"], environ["ZOTERO_USER"], 'user')

HOME = environ.get("HOME", "/home/nobody")
ROOT = environ.get("PHD_ROOT", f"{HOME}/phd")
NOTES = environ.get("PHD_NOTES", f"{ROOT}/notes")
STORAGE = environ.get("ZOTERO_STORAGE", f"{HOME}/.zotero/data/storage")
BIBTEX = environ.get("BIBTEX", f"{NOTES}/references/references.bib")

zotcli.storage_dir = STORAGE

DEBUG = environ.get("ZPOLL_DEBUG", False)

from prettytable import PrettyTable


def display_table(stdscr, data):
  # Clear screen
  stdscr.clear()

  # Get screen size
  height, width = stdscr.getmaxyx()

  # Define column headers
  headers = data[0]

  # Define column data
  rows = data[1:]

  # Create table object
  table = PrettyTable(headers)

  # Add rows to table object
  for row in rows:
    table.add_row(row)

  # Set column alignment to left
  table.align = "l"

  # Set max width of each column
  for i, col in enumerate(headers):
    table.max_width[col] = width // len(headers)

  # Print table to screen
  table_str = table.get_string()
  table_rows = table_str.split("\n")
  table_height = len(table_rows)
  table_width = max(len(row) for row in table_rows)
  x = (width - table_width) // 2
  y = (height - table_height) // 2
  for row in table_rows:
    stdscr.addstr(y, x, row)
    y += 1

  # Refresh screen
  stdscr.refresh()


def loop(stdscr):
  # Disable cursor blinking
  if not DEBUG:
    curses.curs_set(2)
    stdscr.timeout(60000)
    stdscr.keypad(True)

  while True:
    data = [["Error", "Item", "Link"]]

    items = zot.top()

    bibtex = btex.parse_file(BIBTEX)
    keys = [bibtex.entries[e].key for e in bibtex.entries]
    if not DEBUG:
      stdscr.clear()
      stdscr.refresh()
      height, width = stdscr.getmaxyx()
      stdscr.addstr(height // 2, width // 2 - 6, "processing...")
      stdscr.refresh()
    num_synced = zotcli.synchronize()
    prompt = f"Enter quit to end or anything else to refresh (synced {num_synced}): "
    prompted = None

    for item in items:
      key = item["data"].get("extra", "")
      meta = {
          kv[0]: kv[1] for x in key.split("\n") if len(kv := x.split(": ")) == 2
      }
      citeable = meta.get('tex.key', '').replace('-', '_')
      if key and citeable:
        file = f"{NOTES}/literature/{citeable}.pdf"
        note = f"{NOTES}/reviews/{citeable}.md"
        if not path.exists(file):
          attachment = item["links"].get("attachment", None)
          if attachment:
            link = f"{STORAGE}/{os.path.basename(attachment['href'])}"
            source = glob(f"{link}/*.pdf")
            # print(citeable, attachment)
            atype = attachment.get("attachmentType", "")
            if (atype == r'application/pdf'):
              if source:
                source = source[0]
                data.append([f"Moved", str(citeable), "-"])
                shutil.copy(source, file)
              else:
                data.append([f"No such source {link}.***", str(citeable), ""])
            else:
              data.append(
                  [f"Wrong type {atype}",
                   str(citeable),
                   str(attachment)])
          else:
            data.append([f"Missing", str(citeable), str(item['data']['title'])])

        if path.exists(file) and not item["links"].get("attachment", None):
          uploads = [file]
          if path.exists(note):
            uploads.append(note)
          zot.attachment_simple(uploads, item["key"])
      else:
        attachment = item["links"].get("attachment", None)
        if attachment and not prompted:
          tmp = title = ''.join(
              re.sub(r'[^a-zA-Z0-9]', '', item['data']['title']))[:15].lower()
          prompt = f"Title {item['data']['title']} (suggested: {title}) {item['data']['url']}"
          prompt = f"{prompt[:80]} > "
          prompted = item
        else:
          # print(attachment)
          data.append([f"Missing", str(attachment), str(item['data']['title'])])
          # print(f"Missing file for: {item['data']['title']}")

    input_str = ""
    # Display table
    if not DEBUG:
      display_table(stdscr, data)
      prompt = prompt[:width - 15]
      cursor_x = len(prompt)
    else:
      for row in data:
        print(f"{row[0]} {row[1]} {row[2]}")
      input_str = input(prompt)

    while not DEBUG:
      # Display user input at bottom
      stdscr.move(curses.LINES - 1, 0)
      stdscr.clrtoeol()
      stdscr.refresh()
      stdscr.addstr(curses.LINES - 1, 0, prompt + input_str)
      stdscr.move(curses.LINES - 1, cursor_x)
      stdscr.refresh()

      c = stdscr.getch()
      if c == ord('\n') or c == curses.ERR:
        break

      elif c == curses.KEY_BACKSPACE or c == 127:
        if cursor_x > len(prompt):
          cursor_x -= 1
          input_str = input_str[:cursor_x -
                                len(prompt)] + input_str[cursor_x -
                                                         len(prompt) + 1:]
      elif c == curses.KEY_LEFT:
        if cursor_x > len(prompt):
          cursor_x -= 1
      elif c == curses.KEY_RIGHT:
        if cursor_x < curses.COLS - 1:
          cursor_x += 1
          if cursor_x > len(input_str) + len(prompt):
            cursor_x = len(input_str) + len(prompt)
      else:
        if len(input_str) < curses.COLS - 1 - len(prompt):
          input_str = input_str[:cursor_x -
                                len(prompt)] + chr(c) + input_str[cursor_x -
                                                                  len(prompt):]
          cursor_x += 1

    if input_str == "quit":
      break
    if prompted:
      item = prompted
      title = input_str
      attachment = item["links"].get("attachment", None)
      if title == " ":
        title = tmp
      title = title.replace('-', '_')
      title = ''.join(re.sub(r'[^a-zA-Z0-9_-]', '', title)).lower()

      item["data"]["extra"] += f"\ntex.key: {title}"
      zot.update_item(item)

      file = f"{NOTES}/literature/{title}.pdf"
      source = glob(f"{STORAGE}/{os.path.basename(attachment['href'])}/*.pdf")
      if not source or not title:
        # Missing the file
        continue
      source = source[0]
      atype = attachment.get("attachmentType", "")
      if (atype == r"application/pdf" and path.exists(source)):
        shutil.copy(source, file)


def main():
  if DEBUG:
    loop(None)
  else:
    curses.wrapper(loop)


if __name__ == '__main__':
  main()
