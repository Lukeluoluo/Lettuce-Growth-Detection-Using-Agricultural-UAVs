import os
os.environ['GDAL_DATA'] = r'D:\anaconda\envs\uav_rs\Library\share\gdal'
import rasterio
from rasterio.mask import mask
import geopandas as gpd
import numpy as np
import pandas as pd

# ---------------------- 真实路径 ----------------------
multi_tif_path = r"D:\项目\无人机\20250323_DAP54\MULTI\MULTI_202503241214_038_30m_CUT.tif"
sample_shp_path = r"D:\项目\无人机\sample_20plants.shp"
out_ndvi_csv = r"D:\项目\无人机\plant_ndvi_result.csv"
# ----------------------------------------------------------------

gdf_sample = gpd.read_file(sample_shp_path)
result_list = []

with rasterio.open(multi_tif_path) as src_multi:
    for idx, row in gdf_sample.iterrows():
        plotid = row["PlotID"]
        geom = [row["geometry"]]

        # 掩膜裁剪，取出该多边形内多光谱像素
        out_img, out_transform = mask(src_multi, geom, crop=True, nodata=np.nan)
        # band2 → Red；band4 → NIR 数组索引1和3
        red = out_img[1].astype(np.float32)
        nir = out_img[3].astype(np.float32)

        valid_mask = ~np.isnan(red) & ~np.isnan(nir)
        valid_count = np.sum(valid_mask)
        if valid_count < 10:
            result_list.append({"PlotID": plotid, "NDVI_mean": np.nan, "valid_pixel":0})
            continue

        red_valid = red[valid_mask]
        nir_valid = nir[valid_mask]

        # NDVI计算，分母防除0
        denominator = nir_valid + red_valid
        ndvi_valid = np.where(denominator == 0, np.nan, (nir_valid - red_valid) / denominator)
        ndvi_mean = np.nanmean(ndvi_valid)

        result_list.append({
            "PlotID": plotid,
            "NDVI_mean": round(float(ndvi_mean),4),
            "valid_pixel": int(valid_count)
        })

df_ndvi = pd.DataFrame(result_list)
df_ndvi.to_csv(out_ndvi_csv, index=False, encoding="utf-8")
print("====单株NDVI计算完成====")
print(df_ndvi)
print(f"\n结果保存到 {out_ndvi_csv}")