package spacelift



# Prevent any changes that will cause the hourly cost to go above a certain threshold
deny[sprintf("hourly cost greater than $%.2f ($%.2f)", [threshold, hourly_cost])] {
  threshold := 0.01
  hourly_cost := to_number(input.third_party_metadata.infracost.projects[0].breakdown.totalHourlyCost)
  hourly_cost > threshold
}

deny[sprintf("monthly cost greater than $%d ($%.2f)", [threshold, monthly_cost])] {
	threshold := 10
	monthly_cost := to_number(input.third_party_metadata.infracost.projects[0].breakdown.totalMonthlyCost)
	monthly_cost > threshold
}