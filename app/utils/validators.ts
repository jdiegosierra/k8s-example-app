export function isValidUsername(username: string): boolean {
  return /^[A-Za-z]+$/.test(username);
}

export function isValidDate(dateString: string): boolean {
  const date = new Date(dateString);
  if (isNaN(date.getTime())) return false;
  const today = new Date();
  const todayStr = today.toISOString().split("T")[0];
  return date < new Date(todayStr);
} 