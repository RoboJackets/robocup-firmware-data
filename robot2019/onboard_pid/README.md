Note: Only 4 numbers can be recorded wirelessly at once so each batch is done in sets of 2
where the gains are the same, but the actual commands will be different

# WS Data Files

`*_ws_#` files are the output files for the wheel speed to duty cycle gain trails. This is specificlaly to tune the rad/s target -> duty cycle gain for the wheels in general. In a perfect world, during steady state, they should match


`w12` means it's wheel 1 and 2, `w34` means it's wheel 3 and 4.

## Column Description

w12
| Wheel 1 actual (rad/s) | Wheel 2 actual (rad/s) | Wheel 1 target (rad/s) | Wheel 2 target (rad/s) |

w34
| Wheel 3 actual (rad/s) | Wheel 4 actual (rad/s) | Wheel 3 target (rad/s) | Wheel 4 target (rad/s) |

| WS Trial # | Wheel Speed Gain |
| ---------- | ---------------- |
| 1          |              5.0 |
