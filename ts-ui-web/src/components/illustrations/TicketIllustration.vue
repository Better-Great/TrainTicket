<script setup lang="ts"></script>

<template>
  <svg
    class="ticket-illustration"
    viewBox="0 0 200 110"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    aria-hidden="true"
  >
    <path
      d="M8 20a8 8 0 0 1 8-8h160a8 8 0 0 1 8 8v14a10 10 0 0 0 0 20v18a10 10 0 0 0 0 20v10a8 8 0 0 1-8 8H16a8 8 0 0 1-8-8V90a10 10 0 0 0 0-20V54a10 10 0 0 0 0-20V20Z"
      class="stub"
    />
    <path d="M132 12v86" class="perforation" stroke-dasharray="4 5" stroke-linecap="round" />
    <rect x="24" y="30" width="72" height="8" rx="4" class="line line-strong" />
    <rect x="24" y="46" width="52" height="6" rx="3" class="line" />
    <rect x="24" y="60" width="60" height="6" rx="3" class="line" />
    <circle cx="152" cy="42" r="14" class="badge" />
    <path d="M145 42h14M152 35v14" class="badge-mark" stroke-linecap="round" />
    <rect x="140" y="66" width="26" height="6" rx="3" class="line" />
  </svg>
</template>

<style scoped>
.ticket-illustration {
  width: 100%;
  height: auto;
}

.stub {
  fill: var(--paper);
  stroke: var(--line);
  stroke-width: 2;
}

.perforation {
  stroke: var(--line);
  stroke-width: 2;
}

.line {
  fill: var(--line);
}

.line-strong {
  fill: var(--rail);
}

.badge {
  fill: none;
  stroke: var(--signal);
  stroke-width: 3;
}

.badge-mark {
  stroke: var(--signal);
  stroke-width: 3;
}
</style>
