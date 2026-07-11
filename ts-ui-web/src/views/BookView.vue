<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Ticket, MapPin, CalendarDays, Armchair, User, ShieldCheck, CheckCircle2 } from 'lucide-vue-next'
import { createContact, listContacts, preserveTicket } from '@/api/services'
import type { Contact } from '@/api/types'
import { useAuthStore } from '@/stores/auth'
import { documentTypeLabel, formatMoney } from '@/utils/format'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

const tripId = computed(() => String(route.query.tripId ?? ''))
const from = computed(() => String(route.query.from ?? ''))
const to = computed(() => String(route.query.to ?? ''))
const date = computed(() => String(route.query.date ?? ''))
const seatType = computed(() => String(route.query.seatType ?? '3'))
const seatPrice = computed(() => String(route.query.seatPrice ?? ''))

const contacts = ref<Contact[]>([])
const selectedId = ref('')
const assurance = ref(0)
const loading = ref(false)
const error = ref('')
const success = ref('')

const newContact = ref({
  name: '',
  documentType: 1,
  documentNumber: '',
  phoneNumber: '',
})

async function loadContacts() {
  if (!auth.userId) return
  const res = await listContacts(auth.userId)
  contacts.value = res.data ?? []
  if (contacts.value[0]) selectedId.value = contacts.value[0].id
}

async function addContact() {
  if (!auth.userId) return
  const res = await createContact({
    ...newContact.value,
    accountId: auth.userId,
  })
  contacts.value.push(res.data)
  selectedId.value = res.data.id
  newContact.value = { name: '', documentType: 1, documentNumber: '', phoneNumber: '' }
}

async function confirm() {
  if (!selectedId.value) {
    error.value = 'Select a passenger contact.'
    return
  }
  loading.value = true
  error.value = ''
  success.value = ''
  try {
    const res = await preserveTicket({
      accountId: auth.userId,
      contactsId: selectedId.value,
      tripId: tripId.value,
      seatType: seatType.value,
      date: date.value,
      from: from.value,
      to: to.value,
      assurance: assurance.value,
      foodType: 0,
    })
    success.value = `Reserved${res.data?.orderId ? ` · ${res.data.orderId}` : ''}`
    setTimeout(() => router.push({ name: 'orders' }), 700)
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Preserve failed'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  if (!tripId.value) {
    router.replace({ name: 'search' })
    return
  }
  void loadContacts()
})
</script>

<template>
  <section class="page">
    <p class="eyebrow">Booking</p>
    <h1>Confirm trip</h1>

    <div class="summary">
      <div>
        <span><Ticket :size="13" /> Trip</span>
        <strong>{{ tripId }}</strong>
      </div>
      <div>
        <span><MapPin :size="13" /> Route</span>
        <strong>{{ from }} → {{ to }}</strong>
      </div>
      <div>
        <span><CalendarDays :size="13" /> Date</span>
        <strong>{{ date }}</strong>
      </div>
      <div>
        <span><Armchair :size="13" /> Seat</span>
        <strong>
          {{ seatType === '2' ? 'Comfort' : 'Economy' }} · {{ formatMoney(seatPrice) }}
        </strong>
      </div>
    </div>

    <h2><User :size="18" /> Passenger</h2>
    <div class="contacts">
      <label v-for="c in contacts" :key="c.id" class="contact">
        <input v-model="selectedId" type="radio" :value="c.id" />
        <div>
          <strong>{{ c.name }}</strong>
          <p>
            {{ documentTypeLabel(c.documentType) }} · {{ c.documentNumber }} · {{ c.phoneNumber }}
          </p>
        </div>
      </label>
    </div>

    <details class="new">
      <summary>Add contact</summary>
      <form class="new-form" @submit.prevent="addContact">
        <input v-model="newContact.name" placeholder="Name" required />
        <select v-model.number="newContact.documentType">
          <option :value="1">ID Card</option>
          <option :value="2">Passport</option>
          <option :value="3">Other</option>
        </select>
        <input v-model="newContact.documentNumber" placeholder="Document #" required />
        <input v-model="newContact.phoneNumber" placeholder="Phone" required />
        <button type="submit">Save contact</button>
      </form>
    </details>

    <label class="assurance">
      <span><ShieldCheck :size="14" /> Assurance</span>
      <select v-model.number="assurance">
        <option :value="0">No assurance</option>
        <option :value="1">Traffic accident assurance</option>
      </select>
    </label>

    <p v-if="error" class="error" role="alert">{{ error }}</p>
    <p v-if="success" class="ok" role="status"><CheckCircle2 :size="16" /> {{ success }}</p>

    <button class="submit" type="button" :disabled="loading" @click="confirm">
      {{ loading ? 'Reserving…' : 'Confirm reservation' }}
    </button>
  </section>
</template>

<style scoped>
.page {
  max-width: var(--max);
  margin: 0 auto;
  padding: 2rem 1.25rem 3rem;
  width: 100%;
}

.eyebrow {
  text-transform: uppercase;
  letter-spacing: 0.12em;
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--rail);
}

h1 {
  font-size: clamp(2rem, 4vw, 2.6rem);
  margin: 0.25rem 0 1.5rem;
}

.summary {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid var(--line);
  margin-bottom: 1.5rem;
}

.summary span {
  display: flex;
  align-items: center;
  gap: 0.3rem;
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--muted);
  text-transform: uppercase;
  letter-spacing: 0.06em;
}

h2 {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 1.15rem;
  margin-bottom: 0.75rem;
}

.contacts {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.contact {
  display: flex;
  gap: 0.75rem;
  align-items: flex-start;
  padding: 0.85rem 0;
  border-bottom: 1px solid var(--line);
  cursor: pointer;
}

.contact p {
  color: var(--muted);
  font-size: 0.875rem;
}

.new {
  margin: 1rem 0;
}

.new-form {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.5rem;
  margin-top: 0.75rem;
}

input,
select,
button {
  border: 1px solid var(--line);
  background: white;
  padding: 0.65rem 0.75rem;
}

.assurance {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  max-width: 280px;
  font-size: 0.875rem;
  font-weight: 600;
  margin: 1rem 0;
}

.assurance span {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
}

.submit {
  background: var(--signal);
  color: var(--signal-ink);
  border: none;
  font-weight: 800;
  padding: 0.85rem 1.25rem;
  cursor: pointer;
}

.error {
  color: var(--danger);
}
.ok {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  color: var(--ok);
}

@media (max-width: 800px) {
  .summary,
  .new-form {
    grid-template-columns: 1fr 1fr;
  }
}
</style>
