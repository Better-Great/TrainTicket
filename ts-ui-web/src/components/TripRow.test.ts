import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import TripRow from '@/components/TripRow.vue'

describe('TripRow', () => {
  it('emits book and seat updates', async () => {
    const wrapper = mount(TripRow, {
      props: {
        tripId: 'G1234',
        startTime: '09:00',
        endTime: '11:00',
        from: 'Shang Hai',
        to: 'Su Zhou',
        economySeats: 10,
        comfortSeats: 2,
        economyPrice: '75.5',
        comfortPrice: '120',
        selectedSeat: 3,
      },
    })

    expect(wrapper.text()).toContain('G1234')
    expect(wrapper.text()).toContain('¥75.5')

    await wrapper.find('button.book').trigger('click')
    expect(wrapper.emitted('book')).toBeTruthy()

    const radios = wrapper.findAll('input[type="radio"]')
    await radios[1]!.setValue(true)
    expect(wrapper.emitted('update:selectedSeat')?.[0]).toEqual([2])
  })
})
