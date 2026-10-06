/**
 * 查看以下文档了解主题配置
 * - @see https://theme-plume.vuejs.press/config/intro/ 配置说明
 * - @see https://theme-plume.vuejs.press/config/theme/ 主题配置项
 *
 * 请注意，对此文件的修改都会重启 vuepress 服务。
 * 部分配置项的更新没有必要重启 vuepress 服务，建议请在 `.vuepress/config.ts` 文件中配置
 *
 * 特别的，请不要在两个配置文件中重复配置相同的项，当前文件的配置项会被覆盖
 */

import { viteBundler } from '@vuepress/bundler-vite'
import { defineUserConfig } from 'vuepress'
import { plumeTheme } from 'vuepress-theme-plume'

export default defineUserConfig({
  base: '/',
  lang: 'zh-CN',
  title: '开发者笔记',
  description: '所有的伟大都源于一个简单的开始',

  head: [
    // 配置站点图标
    ['link', { rel: 'icon', type: 'image/png', href: 'https://api.iconify.design/token:rtm.svg' }],
    // JetBrains Mono 代码字体
    ['link', { rel: 'preconnect', href: 'https://fonts.googleapis.com' }],
    ['link', { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' }],
    ['link', { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=JetBrains+Mono:ital,wght@0,400;0,500;0,600;0,700;1,400&display=swap' }],
    // 尽早恢复主题色 / 页面尺寸，避免首屏闪烁
    ['script', {}, `(()=>{try{const d=document.documentElement;const b=localStorage.getItem('plume-brand-color');const s=localStorage.getItem('plume-page-size');if(b)d.setAttribute('data-brand',b);if(s)d.setAttribute('data-page-size',s)}catch(e){}})()`],
  ],

  bundler: viteBundler(),

  shouldPrefetch: false, // 站点较大，页面数量较多时，不建议启用

  theme: plumeTheme({
    /* 添加您的部署域名, 有助于 SEO, 生成 sitemap */
    hostname: 'https://wenzhaohui.com',

    /* 文档仓库配置，用于 editLink */
    // docsRepo: '',
    // docsDir: 'docs',
    // docsBranch: '',

    /* 页内信息 */
    editLink: true, // 是否显示编辑链接
    lastUpdated: true, // 是否显示最后更新时间
    contributors: true, // 是否显示贡献者
    changelog: false, // 是否显示更新日志

    /**
     * 编译缓存，加快编译速度
     * @see https://theme-plume.vuejs.press/config/theme/#cache
     */
    cache: 'filesystem',

    /**
     * 为 markdown 文件自动添加 frontmatter 配置
     * @see https://theme-plume.vuejs.press/config/theme/#autofrontmatter
     */
    autoFrontmatter: {
      permalink: true,  // 是否生成永久链接
      createTime: true, // 是否生成创建时间
      title: true,      // 是否生成标题
    },

    /* 本地搜索, 默认启用 */
    search: {
      provider: 'local'
    },

    /**
     * Algolia DocSearch
     * 启用此搜索需要将 本地搜索 search 设置为 false
     * @see https://theme-plume.vuejs.press/config/plugins/search/#algolia-docsearch
     */
    // search: {
    //   provider: 'algolia',
    //   appId: '',
    //   apiKey: '',
    //   indices: [''],
    // },

    /**
     * Shiki 代码高亮 — Atom One Light / One Dark Pro
     * @see https://theme-plume.vuejs.press/config/plugins/code-highlight/
     */
    codeHighlighter: {
      themes: {
        light: 'one-light',
        dark: 'one-dark-pro',
      },
      // 是否显示行号
      lineNumbers: true,
      // 语言标签由 CSS 显示（data-ext），非此配置项控制
    },

    /* 文章字数统计、阅读时间，设置为 false 则禁用 */
    readingTime: true,

    /**
     * markdown
     * @see https://theme-plume.vuejs.press/config/markdown/
     */
    markdown: {
      abbr: true,
      annotation: true,
      plot: true,
      icon: {
        provider: 'iconify',
      },
      table: true,
      npmTo: true,
      demo: true,
      collapse: true,
      image: {
        figure: true,
        lazyload: true,
        mark: true,
        size: true,
      },
      include: true,
      imageSize: 'local',
    },

    /**
     * 水印
     * @see https://theme-plume.vuejs.press/guide/features/watermark/
     */
    watermark: false,

    /**
     * 评论 comments
     * @see https://theme-plume.vuejs.press/guide/features/comments/
     */
    comment: {
      provider: 'Giscus', // "Artalk" | "Giscus" | "Twikoo" | "Waline"
      comment: true,
      repo: 'nicepoem/Giscus',
      repoId: 'R_kgDOTy-YeA',
      category: 'Announcements',
      categoryId: 'DIC_kwDOTy-YeM4DC_A-',
      mapping: 'pathname',
      reactionsEnabled: true,
      inputPosition: 'top',
    },

    /**
     * 资源链接替换
     * @see https://theme-plume.vuejs.press/guide/features/replace-assets/
     */
    // replaceAssets: 'https://cdn.example.com',

    /**
     * 加密功能
     * @see https://theme-plume.vuejs.press/guide/features/encryption/
     */
    // encrypt: {},

    /**
     * 启用 llmstxt 插件，用于为大语言模型提供更友好的内容
     * @see https://theme-plume.vuejs.press/guide/features/llmstxt/
     */
    // llmstxt: {
    //   locale: '/',    // 默认仅为主语言生成 llms 友好内容
    // }
  }),
})
