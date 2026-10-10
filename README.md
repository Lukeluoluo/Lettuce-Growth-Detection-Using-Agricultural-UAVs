```markdown
# 生菜单株无人机遥感表型提取与长势分级分析

本项目基于DJI Mavic3M无人机RGB、多光谱正射影像，结合单株生菜多边形矢量边界，实现逐株提取植被覆盖度FVC、NDVI植被指数；利用NDVI分位数完成植株长势分级；通过FVC‑NDVI一元线性回归残差法识别FVC与NDVI关系异常的植株样本。

## 数据集来源
本项目使用公开生菜无人机表型数据集：
> Adak, Alper (2026). Data and code from: High‑throughput UAV phenomics and machine learning enables accurate early single‑plant biomass prediction in lettuce [Dataset]. Dryad.
> DOI: [10.5061/dryad.73n5tb3d4](https://doi.org/10.5061/dryad.73n5tb3d4)

数据集包含内容：
1. DJI Mavic 3 Multispectral 获取的RGB、多光谱正射镶嵌影像（本项目使用DAP54，30 m航高数据）
2. 单株生菜面矢量文件，一共1080株试验植株，每株具有唯一标识符 PlotID
3. 田间试验设计信息、人工实测表型数据 df_all.txt
4. 原始R语言提取脚本 Code_for_data_extraction_from_ortho.R

说明：本项目使用Python实现指标提取，未使用数据集附带的R脚本。原始遥感影像、原始矢量、df_all.txt等原始数据文件体积较大，不提交至GitHub仓库，可前往Dryad数据集下载。

## Python环境依赖
创建conda环境后安装依赖包：
```bash
conda install rasterio geopandas numpy opencv-python pandas matplotlib scikit-learn
```
依赖包用途：
- rasterio：栅格影像读写、矢量裁剪栅格
- geopandas：矢量处理、投影转换
- opencv‑python：ExG指数、Otsu阈值分割计算植被掩膜
- pandas、numpy：表格处理、数值运算
- matplotlib：统计图表绘制
- scikit‑learn：线性回归，用于FVC‑NDVI残差计算

## 仓库目录结构
```
├── code/
│   └── lettuce_full_all_plants.py
├── testresult/
├── finalresult/
└── README.md
```

本地存放原始数据集，不上传GitHub：
`20250323_DAP54/`

## 源代码说明
### code/lettuce_full_all_plants.py
项目主程序，完整执行流程：
1. 参数配置：设置影像路径、矢量路径、输出目录、长势分级分位数阈值。
2. 矢量处理：读取原始矢量，将坐标系转换为UTM‑32636，匹配无人机影像坐标系。
3. RGB处理：逐株裁剪RGB影像，计算ExG超绿指数，Otsu阈值分割得到植被掩膜，计算单株FVC植被覆盖度，输出all_plant_fvc.csv。
4. 多光谱处理：逐株裁剪多光谱影像，计算单株平均NDVI，输出all_plant_ndvi.csv。
5. 数据表合并：以PlotID作为主键，合并FVC与NDVI数据表。
6. 长势分级：基于NDVI分位数划分4个长势等级。
7. 残差异常检测：FVC为自变量、NDVI_mean为因变量构建一元线性回归，计算残差，标记统计离群样本。
8. 属性回写：将全部计算字段回写至矢量，输出all_plants_utm.gpkg。
9. 统计绘图：生成散点图、箱线图与统计表格。
10. 栅格输出：生成全场植被掩膜、NDVI栅格、像素级长势分级栅格。

## 输出文件说明
testresult为第一次测试运行输出，用于调试对比。
finalresult为正式运行输出。
两套目录内部文件结构一致。GitHub仅保存csv、png、gpkg，体积较大的tif栅格文件仅保存在本地。

### 矢量文件 all_plants_utm.gpkg
GeoPackage矢量格式，单文件存储几何、属性与坐标系，使用QGIS软件打开。

属性字段：
| 字段 | 说明 |
|---|---|
| PlotID | 植株唯一编号，关联全部表格与原始数据集 |
| FVC | 植被覆盖度，0‑1，代表多边形内叶片像素占比 |
| veg_pixel | 识别为植被的像素数量 |
| total_valid_pixel | 矢量框内总有效像素 |
| otsu_threshold | ExG影像Otsu分割阈值 |
| NDVI_mean | 单株多边形内NDVI像素平均值 |
| valid_pixel | 参与NDVI计算的有效像素数 |
| grade_code | 长势分级编码，1长势差，2长势一般，3长势良好，4长势优秀 |
| grade_name | 长势分级文字标签 |
| y_pred | FVC回归得到的NDVI预测值 |
| residual | 残差 = NDVI_mean − y_pred |
| is_abnormal | 残差异常标记，True代表FVC‑NDVI关系统计离群，不等同于错误数据，需要结合影像目视核查 |

### CSV表格文件
#### all_plant_fvc.csv
RGB提取FVC结果，字段包含PlotID、FVC、veg_pixel、total_valid_pixel、otsu_threshold。

#### all_plant_ndvi.csv
多光谱NDVI提取结果，字段包含PlotID、NDVI_mean、valid_pixel。

#### all_plant_merge_result.csv
合并总表，包含FVC、NDVI、长势等级、回归预测值、残差、异常标记。

#### abnormal_plant.csv
残差筛选得到的离群植株子集。该子集仅代表统计上偏离回归趋势，部分样本为真实个体差异，部分由阴影、配准偏差造成，需要目视核查，不建议直接删除样本。

#### summary_statistics.csv
描述性统计，包含各指标计数、均值、标准差、四分位数、FVC‑NDVI相关系数。

#### field_growth_stat.csv
整田栅格统计，各长势等级像素数量以及占比。

### PNG图片文件
#### fvc_ndvi_scatter_all.png
FVC‑NDVI散点图，红色点标记残差异常样本，附带线性拟合线。

#### grade_boxplot.png
不同长势等级FVC箱线图，空心圆圈为1.5倍四分位距判定的组内统计离群点。该离群判定仅针对FVC单指标，与is_abnormal标记相互独立。

### 本地GeoTIFF栅格（不上传GitHub）
| 文件 | 说明 |
|---|---|
| field_fvc_mask.tif | 全场二值植被掩膜，1代表植被，0代表裸土，255代表无效值 |
| field_ndvi.tif | 整田NDVI栅格影像 |
| field_growth_grade.tif | 像素级长势分级栅格，0代表无效值 |

## 概念说明
1. PlotID：全局唯一主键，用于关联矢量、输出表格与原始数据集。
2. is_abnormal：基于FVC‑NDVI回归残差，表征两个指标匹配关系的统计异常，不能直接等同于数据错误。
3. 箱线图空心圆圈：单指标FVC的组内统计离群，和双变量残差异常逻辑不同。
4. FVC来自可见光RGB，表征叶片面积占比；NDVI来自多光谱，表征叶片叶绿素水平，二者相关但不完全等价。

## 复现步骤
1. 从Dryad下载原始数据集，放置本地目录。
2. 打开code/lettuce_full_all_plants.py，修改脚本头部配置，设置影像、矢量路径以及输出目录。
3. 在配置好依赖的conda虚拟环境运行主脚本。
4. 脚本执行完成后，删除输出目录内全部tif文件。
5. 将code、testresult、finalresult、README.md上传至GitHub。

