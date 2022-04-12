#!/usr/bin/env bash
test -z "$(playerctl status | grep Playing)" && echo "⏵" || echo "⏸"
