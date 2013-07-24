import copy
from collections import defaultdict

awards_per_state = defaultdict(int)
cash_per_state
avg_per_state = defaultdict(int)

# trees is a list of all the element trees from a year

for t in trees:
  state = t.getroot().find("Institution").find("StateCode").text()
  award_string = t.getroot().find("AwardAmount").text()
  award = int(award_string)
  awards_per_state[state] += 1
  cash_per_state[state] += award

avg_per_state = copy.deepcopy(cash_per_state)
for state in avg_per_state:
  if awards_per_state[state] > 0: # make sure you don't divide by 0
    avg_per_state[state] /= awards_per_state[state] #take average

