/**
 * 查看以下文档了解主题配置
 * - @see https://theme-plume.vuejs.press/config/intro/ 配置说明
 * - @see https://theme-plume.vuejs.press/config/theme/ 主题配置项
 *
 * 请注意，对此文件的修改不会重启 vuepress 服务，而是通过热更新的方式生效
 * 但同时部分配置项不支持热更新，请查看文档说明
 * 对于不支持热更新的配置项，请在 `.vuepress/config.ts` 文件中配置
 *
 * 特别的，请不要在两个配置文件中重复配置相同的项，当前文件的配置项会覆盖 `.vuepress/config.ts` 文件中的配置
 */

import path from 'node:path'
import { defineThemeConfig } from 'vuepress-theme-plume'
import navbar from './navbar'
import collections from './collections'

/**
 * @see https://theme-plume.vuejs.press/config/theme/
 */
export default defineThemeConfig({
  logo: 'https://api.iconify.design/token:rtm.svg',

  appearance: true,  // 配置 深色模式
  social: [
    { icon: 'github', link: 'https://github.com/nicepoem/vuepress-theme-plume' },
  ],
  navbarSocialInclude: ['github'],
  // aside: true, // 页内侧边栏， 默认显示在右侧
  // outline: [2, 3], // 页内大纲， 默认显示 h2, h3

  /**
   * 文章版权信息
   * @see https://theme-plume.vuejs.press/guide/features/copyright/
   */

  copyright: false, // 是否显示文章版权信息

  prevPage: true,   // 是否启用上一页链接
  nextPage: true,   // 是否启用下一页链接
  createTime: true, // 是否显示文章创建时间

  /* 站点页脚 — 内容由 footer-badges.ts + FooterBadges 组件渲染（Shields.io 风格） */
  footer: {
    message: '',
    copyright: '',
  },

  /**
   * @see https://theme-plume.vuejs.press/config/theme/#profile
   */
  profile: {
    avatar: 'https://api.iconify.design/token:rtm.svg',
    name: '温同学',
    description: '笔记',
    circle: true, // 是否显示圆形头像
    // location: '',
    // organization: '',
  },

  navbar,
  collections, // 文章分类

  /**
   * 公告板
   * @see https://theme-plume.vuejs.press/guide/features/bulletin/
   */
  // bulletin: {
  //   layout: 'top-left',
  //   contentType: 'markdown',
  //   title: '公告板',
  //   contentFile: path.join(__dirname, '_bulletin.md'),
  // },

  /** 过渡动画 
  * @see https://theme-plume.vuejs.press/config/theme/#transition 
  */
  transition: {
    page: true,        // 启用 页面间跳转过渡动画
    postList: true,    // 启用 博客文章列表过渡动画
    appearance: 'fade',  // 启用 深色模式切换过渡动画, 或配置过渡动画类型
  },

})
