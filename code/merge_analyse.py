import os
os.environ['GDAL_DATA'] = r'D:\anaconda\envs\uav_rs\Library\share\gdal'
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# 文件路径
fvc_csv = r"D:\项目\无人机\plant_fvc_result.csv"
ndvi_csv = r"D:\项目\无人机\plant_ndvi_result.csv"
out_merge_csv = r"D:\项目\无人机\plant_merge_result.csv"

# 读取两份表格
df_fvc = pd.read_csv(fvc_csv)
df_ndvi = pd.read_csv(ndvi_csv)

# 通过PlotID内连接合并
df_merge = pd.merge(df_fvc, df_ndvi, on="PlotID", how="inner")
df_merge.to_csv(out_merge_csv, index=False, encoding="utf‑8")

print("====合并后数据表====")
print(df_merge[["PlotID","FVC","NDVI_mean"]])

# 计算皮尔逊相关系数 R
corr = df_merge["FVC"].corr(df_merge["NDVI_mean"])
print(f"\nFVC 与 NDVI_mean 的相关系数 r = {corr:.4f}")

# 绘图：FVC x轴，NDVI y轴
plt.rcParams["font.sans-serif"] = ["SimHei"]
plt.figure(figsize=(8,6))
x = df_merge["FVC"]
y = df_merge["NDVI_mean"]
plt.scatter(x, y, s=60, c="green", alpha=0.7)

# 拟合一元线性
z = np.polyfit(x, y, 1)
p = np.poly1d(z)
plt.plot(x, p(x), "r--", label=f"拟合直线 r={corr:.3f}")

plt.xlabel("FVC 植被覆盖度")
plt.ylabel("NDVI_mean 单株平均NDVI")
plt.title("生菜单株：FVC‑NDVI相关性")
plt.legend()
plt.grid(alpha=0.3)
plt.savefig(r"D:\项目\无人机\fvc_ndvi_scatter.png", dpi=150)
plt.show()

print("\n散点图已保存：fvc_ndvi_scatter.png")
print(f"合并完整表格输出：{out_merge_csv}")
