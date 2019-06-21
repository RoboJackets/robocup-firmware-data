Note: Only 4 numbers can be recorded wirelessly at once so each batch is done in sets of 2
where the gains are the same, but the actual commands will be different

# Estimator Gains Table

| Gain # | Process Noise | Encoder Noise | Gyro Noise | Notes |
| ------ | ------------- | ------------- | ---------- | ----- |
| 1      | 0.1           | 0.1           | 0.1        | Gyro Sensitivity at 250 deg/s. Bumped up to 1000 for next run |
| 2      |               |               |            | 1000 deg/s |
| 3      |               | 0.2           | 0.01       |       |
| 4      | 0.01          | 0.4           |            |       |
| 5      |               |               | 0.001      |       |
| 6      |               |               |            | 200 hz update rate |
| 7      | 0.001         | 0.4           | 0.001      |       |
| 8      | 0.0001        |               |            |       |
| 9      |               | 4             | 0.01       |       |
| 10     |               |               | 1          |       |
| 11     |               |               | 0.1        |       |

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

`sppv_AA_B_C_D_F` files are the setpoint process variables for `AA` axis, with gains `B` on the X axis, `C` on the Y axis, and `D` on the W axis. XY axis are m/s and W is in rad/s. `F` is the estimator gain # which this corresponds to.

## Column Description

| Measured axis 1 | Measured axis 2 | Target axis 1 | Target axis 2 |
| --------------- | --------------- | ------------- | ------------- |


| Run | Notes |
| --- | ----- |
| 1.5_2_1.5_7_1 | On block, limit .1 on all axis |
| 1.5_2_1.5_7_2 | On field |
| 1.5_2_1.5_7_3 | On field, limit .3, .2, .1 |
| 1.5_2_1.5_7_4 | All previous ones were busted. Gains of .02,.02,0, and limit of .5 on every axis |

# WEST Data Files

`west_#` files are the omega estimation comparison between the gyro and encoders for gain # in the estimator gain table. Not every entry exists All units in rad/s. In a non slip world, they should match.

## Column Descriptions
| Gyro Raw | Encoder Raw | Filtered |
| -------- | ----------- | -------- |

# XYEST Data Files

`xyest_#` files are the xy estimation compared to the encoder estimates. All units in m/s. Corresponds to a matching gain # in the estimator gain table.

## Column Descriptions
| X Raw | Y Raw | X Filtered | Y Filtered |
| ----- | ----- | ---------- | ---------- |

| XYEST Trail # | Process Noise | Encoder Noise | Gyro Noise | Corresponding WEST Trail # |
| ------------- | ------------- | ------------- | ---------- | -------------------------- |
| 1             | 0.01          | 0.4           | 0.001      | 5                          |

# Strafe Data Files

There's some weird things with left right movement creating disturbances in the forward backwards axis. These are specific data files pertaining to that movement.

## Column Descriptions

| Measured X | Measured Y | Target X | Target Y |
| ---------- | ---------- | -------- | -------- |

# W Data Files

`w_#` files are the raw commands in terms of `10*% max speed` for the wheels for trial `#`.

## Column Descriptions
| Wheel 1 | Wheel 2 | Wheel 3 | Wheel 4 |
| ------- | ------- | ------- | ------- |

| W Trail # | Notes |
| --------- | ----- |
| 1         | 1.5_2_1.5_6 |
| 2         | 0_0_0_6 |

# EST Data Files

`est_A_#` files are the filtered estimate of position in `m/s` and `rad/s` for trial `#` with estimation gain number `A`.

## Column Description
| X | Y | W |
| - | - | - |
