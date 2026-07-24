import { z } from 'zod'

export const visitSchema = z.object({
  visitStatus: z.enum([
    'CUSTOMER_MET',
    'PARTIAL_PAYMENT_PROMISE',
    'DOOR_LOCKED',
    'REFUSED_TO_PAY',
    'THIRD_PARTY_MET',
  ]),
  remarks: z.string().min(3, 'Remarks must be at least 3 characters'),
  promiseDate: z.string().optional(),
  expectedAmount: z.preprocess(
    (val) => (val === '' || val === undefined ? undefined : Number(val)),
    z.number().min(0).optional()
  ),
})

export type VisitFormData = z.infer<typeof visitSchema>
