/**
 * 页脚 Shields.io 徽章配置
 * @see https://shields.io/
 *
 * 在此文件增删改徽章即可，保存后热更新生效。
 * 也可直接填 `src` 使用完整徽章 / 图片地址。
 */

export interface FooterBadge {
  /** 左侧文字 */
  label?: string
  /** 右侧文字 */
  message: string
  /** 右侧颜色，支持命名色或 hex（如 brightgreen / f1404b） */
  color?: string
  /** 左侧颜色 */
  labelColor?: string
  /** shields 内置 logo 名，如 vue.js / github */
  logo?: string
  /** logo 颜色 */
  logoColor?: string
  /** 徽章样式 */
  style?: 'flat' | 'flat-square' | 'plastic' | 'for-the-badge' | 'social'
  /** 点击跳转链接 */
  link?: string
  /** 无障碍 / alt 文本 */
  alt?: string
  /** 直接指定完整图片 URL（优先于上面的字段） */
  src?: string
}

/** 页脚底部补充文案（支持 HTML）；留空则不显示 */
export const footerCopyright = ''

/**
 * 在数组中添加 / 修改徽章配置
 */
export const footerBadges: FooterBadge[] = [
  {
    label: 'Powered by',
    message: 'VuePress',
    color: '42b883',
    logo: 'vue.js',
    logoColor: 'white',
    link: 'https://v2.vuepress.vuejs.org/',
    alt: 'VuePress',
  },
  {
    label: 'Theme',
    message: 'Plume',
    color: 'f1404b',
    link: 'https://theme-plume.vuejs.press',
    alt: 'vuepress-theme-plume',
  },
  {
    label: '陇ICP备',
    message: '2025024686号',
    color: '0078d4',
    link: 'https://beian.miit.gov.cn/',
    alt: '陇ICP备2025024686号',
  },
  {
    label: '甘公网安备',
    message: '62052102000154号',
    color: '1a56db',
    link: 'http://www.beian.gov.cn/portal/registerSystemInfo?recordcode=62052102000154',
    alt: '甘公网安备62052102000154号',
  },
]
