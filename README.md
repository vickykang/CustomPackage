### 使用方法

```
./auto-pack.sh full_destination_dir full_config_dir apk_dir locals(split with ',', optional)
```
### 参数说明
1. **full_destination_dir:** 输出路径（绝对路径），不能为空，配管配置
2. **full_config_dir:** 配置文件存放的目录路径（绝对路径），不能为空，配管配置
3. **apk_dir:** 预装apk存放的目录路径（绝对路径），不能为空，由用户输入
4. **locals** 区域码，多个区域码以‘``,``’（注意不是中文的‘`，`’）分隔，可为空，支持列表选择及用户输入，列表如下：
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
  - GL

### 输出说明
1. **区域码为空:** full_destination_dir/timestamp/update_NU.zip
2. **区域码不为空:** 以`ID,IT`为例，在full_destination_dir/timestamp/文件夹下会分别输出update_ID.zip, update_IT.zip
