# neurolabware_scanbox_utils_docs
Collected code, issues and experiences about the Neurolabware Mesoscope multiphoton imaging platform and ScanBox software

## Official docs
- http://neurolabware.com/
- https://scanbox.org/ - incomplete and based on some previous version of ScanBox

## Known issues with official ScanBox software / Mesoscope hardware
- [ ] Occasionally, objective moves to some far-away position after end of focus
- [ ] Optotune scheduling for z-stacks of mesoscopic panoramas not working: Optotune doesn't move
- [ ] When turning Knobby control knobs fast in "Coarse" control mode, motion doesn't stop as soon as control knob rotation is stopped
- [ ] In mesoscopic panorama display window, accumulation can't be disabled, which would be required for acquisitions other than time series that don't include motor or remote focus motion

## Collected wisdom
- There is no overcurrent protection of the PMTs, so the user has to make sure that bright lights are off during all acquisitions
- to be continued...
