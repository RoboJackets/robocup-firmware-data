Note: Only 4 numbers can be recorded wirelessly at once so each batch is done in sets of 2
where the gains are the same, but the actual commands will be different

# WS Data Files

`*_ws_#` files are the output files for the wheel speed to duty cycle gain trails. This is specificlaly to tune the rad/s target -> duty cycle gain for the wheels in general. In a perfect world, during steady state, they should match.


`w12` means it's wheel 1 and 2, `w34` means it's wheel 3 and 4. These are fixed width.

## Column Description

w12

| Wheel 1 actual (rad/s) | Wheel 2 actual (rad/s) | Wheel 1 target (rad/s) | Wheel 2 target (rad/s) |
| ---------------------- | ---------------------- | ---------------------- | ---------------------- |

w34
| Wheel 3 actual (rad/s) | Wheel 4 actual (rad/s) | Wheel 3 target (rad/s) | Wheel 4 target (rad/s) |
| ---------------------- | ---------------------- | ---------------------- | ---------------------- |

| WS Trial # | Wheel Speed Gain |
| ---------- | ---------------- |
| 1          |              5.0 |

# SPPV Data Files

`sppv_AA_B_C_D_F` files are the setpoint process variables for `AA` axis, with gains `B` on the X axis, `C` on the Y axis, and `D` on the W axis. XY axis are m/s and W is in rad/s. `F` is the WEST Trial # gains which this corresponds to.

## Column Description

| Measured axis 1 | Measured axis 2 | Target axis 1 | Target axis 2 |
| --------------- | --------------- | ------------- | ------------- |




# WEST Data Files

`west_#` files are the omega estimation comparison between the gyro and encoders. All units in rad/s. In a non slip world, they should match.

## Column Descriptions
| Gyro Raw | Encoder Raw | Filtered |
| -------- | ----------- | -------- |

| WEST Trial # | Process Noise | Encoder Noise | Gyro Noise | Notes |
| ------------ | ------------- | ------------- | ---------- | ----- |
| 1            | 0.1           | 0.1           | 0.1        | Gyro Sensitivity at 250 deg/s. Bumped up to 1000 for next run |
| 2            |               |               |            | 1000 deg/s |
| 3            |               | 0.2           | 0.01       |       |
| 3            | 0.01          | 0.4           |            |       |
| 3            |               |               | 0.001      | Gonna stick with these gains |
