# DualSense Plasmoid

A KDE Plasma 6 panel widget that shows your DualSense controller's battery level and lets you power it off over Bluetooth.

![Panel screenshot](screenshots/panel.png)

## Features

- Battery percentage + charging indicator in the panel
- Freedesktop battery icons (works with any icon theme)
- Power-off button in the popup (Bluetooth only)
- Polls every 30 seconds; gracefully dims when controller is absent

## Dependencies

- **Plasma 6**
- **dualsensectl** on `$PATH` — AUR: `dualsensectl-git`
- **udev rules** from the dualsensectl repo so non-root can access `/dev/hidraw*`

## Install

```bash
./scripts/install.sh
```

To update after editing:

```bash
./scripts/reinstall.sh
```

To remove:

```bash
./scripts/uninstall.sh
```

## Known limitations (v0.1)

- **Power-off is Bluetooth only.** Sending the command over USB does nothing; the button will report an error if the controller is connected via USB. This is a hardware/protocol limitation.
- Single controller only. Multi-controller support requires a UI redesign.
- No lightbar, trigger effects, or mic control — those are planned follow-ups.
- No firmware updates — Sony's protocol is not public.
