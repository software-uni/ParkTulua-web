import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

/* Esta función es clave para crear componentes reutilizables sin que las clases
 * de Tailwind choquen entre sí*/
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
