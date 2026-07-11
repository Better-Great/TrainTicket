<script setup lang="ts"></script>

<template>
  <svg
    class="route-illustration"
    viewBox="0 0 400 90"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    aria-hidden="true"
  >
    <path d="M24 45 H376" class="track" stroke-linecap="round" />
    <path d="M24 45 H376" class="track-dash" stroke-linecap="round" stroke-dasharray="1 14" />

    <g class="stop">
      <circle cx="24" cy="45" r="9" class="node node-start" />
      <circle cx="24" cy="45" r="4" class="node-dot" />
    </g>
    <g class="stop">
      <circle cx="200" cy="45" r="7" class="node" />
    </g>
    <g class="stop">
      <circle cx="376" cy="45" r="9" class="node node-end" />
      <circle cx="376" cy="45" r="4" class="node-dot" />
    </g>
  </svg>
</template>

<style scoped>
.route-illustration {
  width: 100%;
  height: auto;
}

.track {
  stroke: var(--line);
  stroke-width: 3;
}

.track-dash {
  stroke: var(--signal);
  stroke-width: 3;
  opacity: 0.7;
}

.node {
  fill: var(--paper);
  stroke: var(--rail);
  stroke-width: 3;
}

.node-start,
.node-end {
  stroke: var(--signal);
}

.node-dot {
  fill: var(--signal);
}
</style>
