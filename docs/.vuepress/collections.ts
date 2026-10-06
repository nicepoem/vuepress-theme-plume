/**
 * @see https://theme-plume.vuejs.press/guide/collection/
 */
import { defineCollection, defineCollections } from 'vuepress-theme-plume'

function doc(dir: string, title: string) {
  return defineCollection({
    type: 'doc',
    dir,
    linkPrefix: `/${dir}/`,
    title,
    sidebar: 'auto',
  })
}

export default defineCollections([
  doc('javascript', 'JavaScript'),
  doc('c', 'c'),
  doc('python', 'python'),
  doc('java', 'java'),
  doc('mysql', 'mysql'),
  doc('sqlserver', 'sqlserver'),
  doc('oracle', 'oracle'),
  doc('redis', 'redis'),
  doc('linux', 'linux'),
  doc('windows', 'windows'),
  doc('macos', 'macos'),
  doc('git', 'git'),
  doc('计算机网络', '计算机网络'),
])
