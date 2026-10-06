/**
 * @see https://theme-plume.vuejs.press/config/navigation/
 */
import { defineNavbarConfig } from 'vuepress-theme-plume'

export default defineNavbarConfig([
  { text: '首页', link: '/' },
  {
    text: '前端',
    items: [
      { icon: 'material-icon-theme:javascript', text: 'JavaScript', link: '/javascript/' },
    ],
  },
  {
    text: '后端',
    items: [
      { icon: 'fa7-solid:c', text: 'c', link: '/c/' },
      { icon: 'material-icon-theme:python', text: 'python', link: '/python/' },
      { icon: 'devicon:java', text: 'java', link: '/java/' },
    ],
  },
  {
    text: '数据库',
    items: [
      { icon: 'devicon:mysql', text: 'MySql', link: '/mysql/' },
      { icon: 'devicon:microsoftsqlserver', text: 'SqlServer', link: '/sqlserver/' },
      { icon: 'logos:oracle', text: 'Oracle', link: '/oracle/' },
      { icon: 'devicon:redis', text: 'Redis', link: '/redis/' },
    ],
  },
  {
    text: '操作系统',
    items: [
      { icon: 'devicon:linux', text: 'Linux', link: '/linux/' },
      { icon: 'brandico:win8', text: 'Windows', link: '/windows/' },
      { icon: 'qlementine-icons:mac-24', text: 'MacOS', link: '/macos/' },
    ],
  },
  { text: 'Git', link: '/git/' },
  { text: '计算机网络', link: '/计算机网络/' },
])
