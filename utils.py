# utils.py
def distribute_proportionally(weights, total_amount):
    total_weight = sum(weights)
    distribution = [int(total_amount * (weight / total_weight)) for weight in weights]
    discrepancy = total_amount - sum(distribution)
    distribution[-1] += discrepancy
    return distribution
    