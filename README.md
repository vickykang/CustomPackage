### 参数说明
1. **Input destination path:** 目标路径，即输出的完整路径
2. **Input config path:** 配置文件所存放的完整目录路径
3. **Input full directory path with preinstalled apks:** 预装apk存放的完整目录路径
4. **Package menu... pick one:** 预装包的类型，单选，默认`GameLoft`
  - GameLoft
  - GameLoft_Yandex
5. **Local menu... pick one or more(split with '|':IN|IT|RU)**: 预装包的区域信息，多选或不选，`ALL`为全选，默认为空，多选以`|`分割。
  - ALL
  - ES
  - ID
  - IN
  - IT
  - KZ
  - MM
  - MY
  - PH
  - PK
  - RU
  - SG
  - TH
  - UA
  - VN

### 输出说明
假设用户选择了`GameLoft`包
- **区域参数为空：** 输出为`destination/GameLoft/yymmddHHMMSS/update.zip`，其中`destination`为第一个参数的目录路径，
- **区域参数不为空:** 除了`destination/GameLoft/yymmddHHMMSS/update.zip`，每个区域会生成`destination/GameLoft/yymmddHHMMSS/update_XX.zip`的包，其中`XX`为区域码。

`GameLoft_Yandex`包也是相同的。
