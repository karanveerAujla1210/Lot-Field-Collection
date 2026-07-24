import { z } from 'zod'

export const paymentSchema = z.object({
  amount: z.preprocess(
    (val) => (val === '' || val === undefined ? undefined : Number(val)),
    z.number().min(1, 'Amount must be greater than 0')
  ),
  paymentMode: z.enum(['CASH', 'UPI', 'CHEQUE', 'NEFT']),
  referenceUpi: z.string().optional(),
  referenceCheque: z.string().optional(),
  referenceNeft: z.string().optional(),
  notes: z.string().optional(),
})

export type PaymentFormData = z.infer<typeof paymentSchema>
