<script setup lang="ts">
import { formatMoney } from '@/utils/format'

defineProps<{
  tripId: string
  startTime: string
  endTime: string
  from: string
  to: string
  economySeats: number
  comfortSeats: number
  economyPrice: string | number
  comfortPrice: string | number
  selectedSeat: 2 | 3
}>()

defineEmits<{
  'update:selectedSeat': [value: 2 | 3]
  book: []
}>()
</script>

<template>
  <article class="trip">
    <div class="times">
      <div>
        <p class="clock">{{ startTime }}</p>
        <p class="stop">{{ from }}</p>
      </div>
      <div class="rail" aria-hidden="true">
        <span class="dot" />
        <span class="track" />
        <span class="dot" />
      </div>
      <div class="end">
        <p class="clock">{{ endTime }}</p>
        <p class="stop">{{ to }}</p>
      </div>
    </div>

    <div class="meta">
      <p class="id">{{ tripId }}</p>
      <div class="seats">
        <label class="seat">
          <input
            type="radio"
            :checked="selectedSeat === 3"
            @change="$emit('update:selectedSeat', 3)"
          />
          <span>
            Economy · {{ formatMoney(economyPrice) }}
            <small>{{ economySeats }} left</small>
          </span>
        </label>
        <label class="seat">
          <input
            type="radio"
            :checked="selectedSeat === 2"
            @change="$emit('update:selectedSeat', 2)"
          />
          <span>
            Comfort · {{ formatMoney(comfortPrice) }}
            <small>{{ comfortSeats }} left</small>
          </span>
        </label>
      </div>
    </div>

    <button type="button" class="book" @click="$emit('book')">Book</button>
  </article>
</template>

<style scoped>
.trip {
  display: grid;
  grid-template-columns: 1.4fr 1.2fr auto;
  gap: 1.25rem;
  align-items: center;
  padding: 1.25rem 0;
  border-bottom: 1px solid var(--line);
  animation: rise 0.45s ease both;
}

@keyframes rise {
  from {
    opacity: 0;
    transform: translateY(8px);
  }
  to {
    opacity: 1;
    transform: none;
  }
}

.times {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  gap: 0.75rem;
  align-items: center;
}

.clock {
  font-family: var(--font-display);
  font-size: 1.5rem;
  font-weight: 700;
}

.stop {
  color: var(--muted);
  font-size: 0.875rem;
}

.end {
  text-align: right;
}

.rail {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  min-width: 4rem;
}

.dot {
  width: 0.45rem;
  height: 0.45rem;
  border-radius: 50%;
  background: var(--rail);
}

.track {
  flex: 1;
  height: 2px;
  background: linear-gradient(90deg, var(--rail), var(--signal));
}

.id {
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.seats {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.seat {
  display: flex;
  gap: 0.5rem;
  align-items: flex-start;
  font-size: 0.9rem;
  cursor: pointer;
}

.seat small {
  display: block;
  color: var(--muted);
  font-size: 0.75rem;
}

.book {
  background: var(--signal);
  color: var(--signal-ink);
  border: none;
  font-weight: 800;
  padding: 0.7rem 1.2rem;
  cursor: pointer;
  transition: transform 0.15s ease, filter 0.15s ease;
}

.book:hover {
  filter: brightness(1.05);
  transform: translateY(-1px);
}

@media (max-width: 800px) {
  .trip {
    grid-template-columns: 1fr;
  }

  .book {
    width: 100%;
  }
}
</style>
