import os
os.environ['GDAL_DATA'] = r'D:\anaconda\envs\uav_rs\Library\share\gdal'
import rasterio
from rasterio.mask import mask
import geopandas as gpd
import numpy as np
import cv2
import pandas as pd

# ---------------------- 真实路径 ----------------------
rgb_tif_path = r"D:\项目\无人机\20250323_DAP54\RGB\RGB_DJI_202503241214_038_30m_CUT.tif"
sample_shp_path = r"D:\项目\无人机\sample_20plants.shp"
out_fvc_csv = r"D:\项目\无人机\plant_fvc_result.csv"
# ----------------------------------------------------------------

# 读取抽样20株矢量
gdf_sample = gpd.read_file(sample_shp_path)

result_list = []

with rasterio.open(rgb_tif_path) as src_rgb:
    for idx, row in gdf_sample.iterrows():
        plotid = row["PlotID"]
        geom = [row["geometry"]]

        # 按单株多边形掩膜裁剪RGB，得到该植株范围内像素
        out_img, out_transform = mask(src_rgb, geom, crop=True, nodata=np.nan)
        # out_img shape:(3,H,W)  波段顺序R G B
        r = out_img[0].astype(np.float32)
        g = out_img[1].astype(np.float32)
        b = out_img[2].astype(np.float32)

        # 过滤nan无效像素
        valid_mask = ~np.isnan(r)
        if np.sum(valid_mask) < 10:
            # 有效像素太少，标记为缺失
            result_list.append({"PlotID": plotid, "FVC": np.nan, "valid_pixel": 0})
            continue

        # 归一化到0‑1（DN值除以255）
        r_norm = r[valid_mask]/255.0
        g_norm = g[valid_mask]/255.0
        b_norm = b[valid_mask]/255.0

        # 计算ExG = 2G - R - B
        exg = 2*g_norm - r_norm - b_norm

        # Otsu大津阈值分割：输入需要0‑255的uint8
        exg_scaled = ((exg - exg.min())/(exg.max()-exg.min())*255).astype(np.uint8)
        otsu_thresh, binary = cv2.threshold(exg_scaled,0,255,cv2.THRESH_BINARY + cv2.THRESH_OTSU)

        # binary=255代表植被
        veg_pixel = np.sum(binary == 255)
        total_valid = exg_scaled.shape[0]
        fvc = veg_pixel / total_valid

        result_list.append({
            "PlotID": plotid,
            "FVC": round(fvc,4),
            "veg_pixel": int(veg_pixel),
            "total_valid_pixel": int(total_valid),
            "otsu_threshold": round(float(otsu_thresh),2)
        })

# 输出csv表格
df_fvc = pd.DataFrame(result_list)
df_fvc.to_csv(out_fvc_csv, index=False, encoding="utf-8")
print("====单株FVC计算完成====")
print(df_fvc)
print(f"\n结果已保存到 {out_fvc_csv}")
