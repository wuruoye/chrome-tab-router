# 菜单图片提亮记录

用户要求提亮第一张商店图片的菜单区域。使用内置 `image_gen` 编辑原始菜单截图，输出保存为 [mac-menu-light.png](../assets/mac-menu-light.png)，尺寸为 1005×1566。原图 [mac-menu-1.3.0.jpg](../assets/mac-menu-1.3.0.jpg) 保留。

提亮版本用于商店材料排版。已逐项视觉核对菜单文字、勾选状态、顺序、分隔线和子菜单箭头；本次只调整图片观感，不改变应用设置。

生成提示：

```text
Edit the provided macOS menu screenshot ONLY to brighten its background. This is a real software screenshot used for a Chrome Web Store listing, so exact UI fidelity is essential. Replace the dark medium-gray menu panel background with a clean very light cool gray near #f3f4f5, like a macOS light appearance menu. Keep dark menu text dark and crisp, and make the disabled status text readable medium gray. Preserve every Chinese and English character verbatim, every checkmark, arrow, separator line, indentation, ordering, rounded corner, and every existing on/off state. Do not add or remove anything, do not rewrite text, do not redesign the UI, do not add a heading or decoration. Preserve the original full composition and aspect ratio; no crop. Primary change is lifting the menu background from dark gray to near-white for a much brighter readable screenshot.
```
