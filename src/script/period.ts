export class Month {
  constructor(
    public year: number,
    public month: number
  ) {
  }
}
export class Period {
  constructor(
    public start: Month,
    public end: Month
  ) {
  }
}
export function calcUsingPeriod(isCurrent: boolean, ...period: Period[]): string {
  let totalMonth = 0
  let endDate = ""
  period.forEach(value => {
    totalMonth += (value.end.year - value.start.year) * 12
    totalMonth += value.end.month - value.start.month
    endDate = `${value.end.year}年${value.end.month}月`
  })
  return "約" + (Math.round((totalMonth / 12) * 10) / 10) + "年" + (isCurrent ? `(${endDate}時点、現在まで)` : "")
}