--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--
import Control.Monad (join, when)
import qualified Data.Map as M
import Data.Maybe (maybeToList)
import Data.Monoid ()
import Graphics.X11.ExtraTypes.XF86
  ( xF86XK_AudioLowerVolume,
    xF86XK_AudioMute,
    xF86XK_AudioNext,
    xF86XK_AudioPlay,
    xF86XK_AudioPrev,
    xF86XK_AudioRaiseVolume,
    xF86XK_MonBrightnessDown,
    xF86XK_MonBrightnessUp,
  )
import System.Exit ()
import XMonad
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.ManageDocks
  ( Direction2D (D, L, R, U),
    avoidStruts,
    docks,
    manageDocks,
  )
import XMonad.Hooks.ManageHelpers (doFullFloat, isFullscreen)
import XMonad.Layout.Fullscreen
  ( FullscreenMessage (AddFullscreen, RemoveFullscreen),
    fullscreenEventHook,
    fullscreenFloat,
    fullscreenFull,
    fullscreenManageHook,
    fullscreenSupport,
  )
import XMonad.Layout.Gaps
  ( Direction2D (D, L, R, U),
    GapMessage (DecGap, IncGap, ToggleGaps),
    gaps,
    setGaps,
  )
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing (Border (Border), spacingRaw, toggleScreenSpacingEnabled)
import XMonad.Layout.ToggleLayouts
import qualified XMonad.StackSet as W
import XMonad.Util.SpawnOnce (spawnOnce)

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--

-- TODO Collect into def {}
myTerminal = "kitty"

background = "~/.backgrounds/punk.jpg"

picom = "~/.config/compton.cfg"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++
--
myWorkspaces = map show [1 .. 9]

--
-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor = "#3b4252"
myFocusedBorderColor = "#FFD13D"

-- TODO: Create instance for eww groups
-- Eww
eww_command command = unwords . (++) ["exec eww " ++ command]
eww_open = eww_command "open-many"
eww_close = eww_command "close"
eww_launch :: [[Char]] -> X ()
eww_launch = spawn . eww_open
eww_destroy = spawn . eww_close
eww_toggle widgets =
  spawn $
    unwords
      [ conditional, "&&",
        eww_open widgets,
        "||",
        eww_close widgets ]
  where
    conditional = "test -z $(eww windows | grep \"*" ++ (head widgets) ++ "\")"

sidebar_widgets =
  [ "weather_side",
    "time_side",
    "smol_calendar",
    "player_side",
    "sys_side",
    "sliders_side"
  ]

sidebar_launch = eww_launch sidebar_widgets
sidebar_destroy = eww_destroy sidebar_widgets
sidebar_toggle = eww_toggle sidebar_widgets

bar_widgets = ["desktop", "time_top"]
bar_launch = eww_launch bar_widgets

-- TODO: Move to support
addNETSupported :: Atom -> X ()
addNETSupported x = withDisplay $ \dpy -> do
  r <- asks theRoot
  a_NET_SUPPORTED <- getAtom "_NET_SUPPORTED"
  a <- getAtom "ATOM"
  liftIO $ do
    sup <- (join . maybeToList) <$> getWindowProperty32 dpy a_NET_SUPPORTED r
    when (fromIntegral x `notElem` sup) $
      changeProperty32 dpy r a_NET_SUPPORTED a propModeAppend [fromIntegral x]

addEWMHFullscreen :: X ()
addEWMHFullscreen = do
  wms <- getAtom "_NET_WM_STATE"
  wfs <- getAtom "_NET_WM_STATE_FULLSCREEN"
  mapM_ addNETSupported [wms, wfs]

firefoxFullscreenSupport = addEWMHFullscreen

-- Infix (,) to clean up key and mouse bindings
infixr 0 ~>

(~>) :: a -> b -> (a, b)
(~>) = (,)

--
------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--

maimcopy = spawn "maim -s | xclip -selection clipboard -t image/png"
maimsave = spawn "maim ~/$(date +%Y-%m-%d_%H-%M-%S).png"
rofi_launcher = spawn "rofi -no-lazy-grab -show drun -modi run,drun,window -theme $HOME/.config/rofi/launcher/style"
rofi_help = spawn ("rofi -modi run,drun,window -theme $HOME/.config/rofi/help/style -e \"$(echo -e \"" ++ help ++ "\")\"")

myKeys conf@(XConfig {XMonad.modMask = modm}) =
  M.fromList $
    -- launch a terminal
    [ (modm, xK_Return) ~> spawn $ XMonad.terminal conf,
      -- lock screen
      (modm .|. shiftMask, xK_l) ~> spawn "betterlockscreen -l",
      -- launch rofi and dashboard
      (modm, xK_space) ~> rofi_launcher,
      -- launch eww sidebar
      (modm, xK_Tab) ~> sidebar_toggle,
      -- Audio keys
      (0, xF86XK_AudioPlay) ~> spawn "playerctl play-pause",
      (0, xF86XK_AudioPrev) ~> spawn "playerctl previous",
      (0, xF86XK_AudioNext) ~> spawn "playerctl next",
      (0, xF86XK_AudioRaiseVolume) ~> spawn "pactl set-sink-volume 0 +5%",
      (0, xF86XK_AudioLowerVolume) ~> spawn "pactl set-sink-volume 0 -5%",
      (0, xF86XK_AudioMute) ~> spawn "pactl set-sink-mute 0 toggle",
      -- Brightness keys
      (0, xF86XK_MonBrightnessUp) ~> spawn "brightnessctl s +10%",
      (0, xF86XK_MonBrightnessDown) ~> spawn "brightnessctl s 10-%",
      -- Screenshot
      (0, xK_Print) ~> maimcopy,
      (modm, xK_Print) ~> maimsave,
      -- close focused window
      (modm .|. shiftMask, xK_w) ~> kill,
      -- GAPS!!!
      (modm .|. controlMask, xK_g) ~> sendMessage $ ToggleGaps, -- toggle all gaps
      (modm .|. shiftMask, xK_g) ~> sendMessage $ setGaps [(L, 30), (R, 30), (U, 40), (D, 60)], -- reset the GapSpec
      (modm .|. controlMask, xK_t) ~> sendMessage $ IncGap 10 L, -- increment the left-hand gap
      (modm .|. shiftMask, xK_t) ~> sendMessage $ DecGap 10 L, -- decrement the left-hand gap
      (modm .|. controlMask, xK_y) ~> sendMessage $ IncGap 10 U, -- increment the top gap
      (modm .|. shiftMask, xK_y) ~> sendMessage $ DecGap 10 U, -- decrement the top gap
      (modm .|. controlMask, xK_u) ~> sendMessage $ IncGap 10 D, -- increment the bottom gap
      (modm .|. shiftMask, xK_u) ~> sendMessage $ DecGap 10 D, -- decrement the bottom gap
      (modm .|. controlMask, xK_i) ~> sendMessage $ IncGap 10 R, -- increment the right-hand gap
      (modm .|. shiftMask, xK_i) ~> sendMessage $ DecGap 10 R, -- decrement the right-hand gap

      -- Toggle Full Screen
      (modm, xK_f) ~> sequence_ [sidebar_destroy, sendMessage (Toggle "Full")],
      -- Rotate through the available layout algorithms
      (modm, xK_n) ~> sendMessage NextLayout,
      --  Reset the layouts on the current workspace to default
      (modm .|. shiftMask, xK_n) ~> setLayout $ XMonad.layoutHook conf,
      -- Resize viewed windows to the correct size
      (modm, xK_r) ~> refresh,
      -- Move focus to the next window
      (modm, xK_j) ~> windows W.focusDown,
      -- Move focus to the previous window
      (modm, xK_k) ~> windows W.focusUp,
      -- Move focus to the master window
      (modm, xK_m) ~> windows W.focusMaster,
      -- Swap the focused window and the master window
      (modm .|. shiftMask, xK_Return) ~> windows W.swapMaster,
      -- Swap the focused window with the next window
      (modm .|. shiftMask, xK_j) ~> windows W.swapDown,
      -- Swap the focused window with the previous window
      (modm .|. shiftMask, xK_k) ~> windows W.swapUp,
      -- Shrink the master area
      (modm, xK_h) ~> sendMessage Shrink,
      -- Expand the master area
      (modm, xK_l) ~> sendMessage Expand,
      -- Push window back into tiling
      (modm, xK_t) ~> withFocused $ windows . W.sink,
      -- Increment the number of windows in the master area
      (modm, xK_comma) ~> sendMessage (IncMasterN 1),
      -- Deincrement the number of windows in the master area
      (modm, xK_period) ~> sendMessage (IncMasterN (-1)),
      -- Restart xmonad
      (modm, xK_q) ~> spawn "xmonad --recompile; xmonad --restart",
      -- Run rofi with a summary of the default keybindings (useful for beginners)
      (modm .|. shiftMask, xK_slash) ~> rofi_help
    ]
      ++
      --
      -- mod-[1..9], Switch to workspace N
      -- mod-shift-[1..9], Move client to workspace N
      --
      [ (m .|. modm, k) ~> windows $ f i
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9],
          (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
      ]
      ++
      --
      -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
      -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
      --
      [ ((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_a, xK_b, xK_c] [0 ..],
          (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
      ]

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) =
  M.fromList $
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ( (modm, button1),
        ( \w ->
            focus w >> mouseMoveWindow w
              >> windows W.shiftMaster
        )
      ),
      -- mod-button2, Raise the window to the top of the stack
      ((modm, button2), (\w -> focus w >> windows W.shiftMaster)),
      -- mod-button3, Set the window to floating mode and resize by dragging
      ( (modm, button3),
        ( \w ->
            focus w >> mouseResizeWindow w
              >> windows W.shiftMaster
        )
      )
      -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = avoidStruts (tiled ||| Mirror tiled)
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled = Tall nmaster delta ratio
    -- The default number of windows in the master pane
    nmaster = 1
    -- Default proportion of screen occupied by master pane
    ratio = 1 / 2
    -- Percent of screen to increment by when resizing panes
    delta = 3 / 100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook =
  fullscreenManageHook <+> manageDocks
    <+> composeAll
      [ resource =? "desktop_window" --> doIgnore,
        isFullscreen --> doFullFloat
      ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook

--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  spawnOnce "exec eww daemon"
  spawnOnce "polybar bar"
  spawn "xsetroot -cursor_name left_ptr"
  spawnOnce $ "feh --bg-scale " ++ background
  spawnOnce $ "picom --experimental-backends --config " ++ picom
  spawnOnce "dunst"
  bar_launch

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = xmonad $ fullscreenSupport $ docks $ ewmh defaults

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults =
  def
    { -- simple stuff
      terminal = myTerminal,
      focusFollowsMouse = myFocusFollowsMouse,
      clickJustFocuses = myClickJustFocuses,
      borderWidth = myBorderWidth,
      modMask = myModMask,
      workspaces = myWorkspaces,
      normalBorderColor = myNormalBorderColor,
      focusedBorderColor = myFocusedBorderColor,
      -- key bindings
      keys = myKeys,
      mouseBindings = myMouseBindings,
      -- hooks, layouts
      manageHook = myManageHook,
      layoutHook = toggleLayouts (smartBorders Full) $ gaps [(L, 30), (R, 30), (U, 40), (D, 60)] $ spacingRaw False (Border 10 10 10 10) True (Border 10 10 10 10) True $ smartBorders $ myLayout,
      handleEventHook = myEventHook,
      logHook = myLogHook,
      startupHook = myStartupHook >> firefoxFullscreenSupport
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help =
  unlines
    [ "The default modifier key is 'super'. Default keybindings:",
      "",
      "-- launching and killing programs",
      "mod-Shift-Enter  Launch xterminal",
      "mod-p            Launch dmenu",
      "mod-Shift-p      Launch gmrun",
      "mod-Shift-c      Close/kill the focused window",
      "mod-Space        Rotate through the available layout algorithms",
      "mod-Shift-Space  Reset the layouts on the current workSpace to default",
      "mod-n            Resize/refresh viewed windows to the correct size",
      "",
      "-- move focus up or down the window stack",
      "mod-Tab        Move focus to the next window",
      "mod-Shift-Tab  Move focus to the previous window",
      "mod-j          Move focus to the next window",
      "mod-k          Move focus to the previous window",
      "mod-m          Move focus to the master window",
      "",
      "-- modifying the window order",
      "mod-Return   Swap the focused window and the master window",
      "mod-Shift-j  Swap the focused window with the next window",
      "mod-Shift-k  Swap the focused window with the previous window",
      "",
      "-- resizing the master/slave ratio",
      "mod-h  Shrink the master area",
      "mod-l  Expand the master area",
      "",
      "-- floating layer support",
      "mod-t  Push window back into tiling; unfloat and re-tile it",
      "",
      "-- increase or decrease number of windows in the master area",
      "mod-comma  (mod-,)   Increment the number of windows in the master area",
      "mod-period (mod-.)   Deincrement the number of windows in the master area",
      "",
      "-- quit, or restart",
      "mod-Shift-q  Quit xmonad",
      "mod-q        Restart xmonad",
      "mod-[1..9]   Switch to workSpace N",
      "",
      "-- Workspaces & screens",
      "mod-Shift-[1..9]   Move client to workspace N",
      "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
      "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
      "",
      "-- Mouse bindings: default actions bound to mouse events",
      "mod-button1  Set the window to floating mode and move by dragging",
      "mod-button2  Raise the window to the top of the stack",
      "mod-button3  Set the window to floating mode and resize by dragging"
    ]
