<script setup lang="ts">
withDefaults(
  defineProps<{
    animated?: boolean
  }>(),
  { animated: true },
)
</script>

<template>
  <svg
    class="train-illustration"
    :class="{ animated }"
    viewBox="0 0 480 160"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    aria-hidden="true"
  >
    <line x1="0" y1="146" x2="480" y2="146" class="rail" />
    <line x1="0" y1="152" x2="480" y2="152" class="rail rail-2" />

    <g class="car car-3">
      <rect x="332" y="58" width="120" height="66" rx="4" class="body" />
      <rect x="346" y="72" width="26" height="24" rx="2" class="window" />
      <rect x="380" y="72" width="26" height="24" rx="2" class="window" />
      <rect x="414" y="72" width="26" height="24" rx="2" class="window" />
      <circle cx="356" cy="124" r="10" class="wheel" />
      <circle cx="428" cy="124" r="10" class="wheel" />
    </g>

    <g class="car car-2">
      <rect x="196" y="52" width="128" height="72" rx="4" class="body" />
      <rect x="212" y="68" width="28" height="26" rx="2" class="window" />
      <rect x="248" y="68" width="28" height="26" rx="2" class="window" />
      <rect x="284" y="68" width="28" height="26" rx="2" class="window" />
      <circle cx="222" cy="124" r="11" class="wheel" />
      <circle cx="298" cy="124" r="11" class="wheel" />
    </g>

    <g class="loco">
      <path
        d="M28 124V70c0-13 10-24 23-26l45-8c9-2 18 1 24 8l16 18h36c8 0 14 6 14 14v48H28Z"
        class="body loco-body"
      />
      <circle cx="86" cy="46" r="7" class="headlight" />
      <rect x="52" y="66" width="30" height="26" rx="2" class="window loco-window" />
      <circle cx="54" cy="124" r="12" class="wheel" />
      <circle cx="130" cy="124" r="12" class="wheel" />
    </g>
  </svg>
</template>

<style scoped>
.train-illustration {
  width: 100%;
  height: auto;
  overflow: visible;
}

.rail {
  stroke: var(--line);
  stroke-width: 2;
}

.rail-2 {
  stroke: var(--mist);
}

.body {
  fill: var(--rail);
}

.loco-body {
  fill: var(--ink);
}

.window {
  fill: var(--paper);
  opacity: 0.9;
}

.loco-window {
  fill: var(--signal);
  opacity: 0.95;
}

.headlight {
  fill: var(--signal);
}

.wheel {
  fill: var(--ink);
}

.animated .loco,
.animated .car {
  animation: chug 2.6s ease-in-out infinite;
}

.animated .car-2 {
  animation-delay: 0.06s;
}

.animated .car-3 {
  animation-delay: 0.12s;
}

@keyframes chug {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-2px);
  }
}

@media (prefers-reduced-motion: reduce) {
  .animated .loco,
  .animated .car {
    animation: none;
  }
}
</style>
