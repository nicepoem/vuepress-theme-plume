/**
 * @see https://theme-plume.vuejs.press/config/navigation/ 查看文档了解配置详情
 *
 * Navbar 配置文件，它在 `.vuepress/plume.config.ts` 中被导入。
 */

import { defineNavbarConfig } from 'vuepress-theme-plume'

export default defineNavbarConfig([
  { text: '首页', link: '/' },
  {
    text: '前端',
    items: [
      { icon: 'material-icon-theme:javascript', text: 'JavaScript', link: '/javascript/' }
    ]
  },
  {
    text: '后端',
    items: [
      { icon: 'fa7-solid:c', text: 'c', link: '/c/' },
      { icon: 'material-icon-theme:python', text: 'python', link: '/python/' },
      { icon: 'devicon:java', text: 'java', link: '/java/' },
    ]
  },
  {
    text: '数据库',
    items: [
      { icon: 'devicon:mysql', text: 'MySql', link: '/mysql/' },
      { icon: 'devicon:microsoftsqlserver', text: 'SqlServer', link: '/sqlserver/' },
      { icon: 'logos:oracle', text: 'Oracle', link: '/oracle/' },
      { icon: 'devicon:redis', text: 'Redis', link: '/redis/' },

    ]
  },
  {
    text: '操作系统',
    items: [
      { icon: 'devicon:linux', text: 'Linux', link: '/linux/' },
      { icon: 'brandico:win8', text: 'Windowns', link: '/windowns/' },
      { icon: 'qlementine-icons:mac-24', text: 'MacOS', link: '/macos/' },
    ]
  },

  { text: '博客', link: '/blog/' },
  { text: '标签', link: '/blog/tags/' },
  { text: '归档', link: '/blog/archives/' },
  // {
  //   text: '笔记',
  //   items: [{ text: '示例', link: '/demo/README.md' }]
  // },
])
