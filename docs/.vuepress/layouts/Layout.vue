<script setup lang="ts">
import { Layout } from 'vuepress-theme-plume/client'
import DocMetaBar from '../theme/components/DocMetaBar.vue'
import FooterBadges from '../theme/components/FooterBadges.vue'
</script>

<template>
  <Layout>
    <template #doc-meta-before>
      <DocMetaBar />
    </template>
    <template #footer-content>
      <FooterBadges />
    </template>
  </Layout>
</template>
