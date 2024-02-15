# Webai Staking Contract

## Structure

### Data Structures

- `stakes` - A mapping of an id and an address which points to an array of `Staking`. Plausible use is inferred as one ID per Plan. A user can have multiple stakes in a plan.

## Notes

- Plan Struct - `initialPool` is not used in the contract.

- Library `SafeERC20` is declared but unused in the entirety of the contract.

- The use of an abstract contract adds unnecesary complexity to the contract, recommended to use an interface instead.

- Although solidity version `^0.8.0` is specified, the contract still uses `SafeMath` library. This is not necessary as the arithmetic operators are checked for overflow and underflow in the latest version of solidity.

- The contract must use a specific pragma version.

- `totalRewardsPerWalletPerPlan` check if this is used as something internal, if external only, would recommend removing it in favor of having a per Staking amount and calculated in an external function for the UI.

- Recommend adding a `createPool` to add all the data in a single transaction.

- Staking contract has a lot of unnecessary checks if the plan limit is only of 1.

- There are multiple instances of constants used in the contract. It is recommended to abstract these into a single location to make it easier to read.

  `e.g. uint256 public constant BASIS_PERCENTAGE = 100;`

- **CRITICAL** There is a missing check for reward tokens vs staked tokens. This could lead to a situation where the contract is unable to pay out the staked amount of users or users cannibalizing other user's funds. Recommend adding a check for the reward token balance before allowing a user to claim rewards and update reward balance on every deposit and withdrawal. Allowing anyone to add tokens to the contract as a reward balance and offsetting the staked amount in a separate variable to keep control.

- `maxDepositDeduction`, `maxWithdrawDeduction`, `maxEarlyPenaly` and `minAPR` should be set as constant or immutable since they are only set once.

### Missing Events

- Staking Conclude Change status.
- Change Penalty Event.
- Change Deposit Deduction amount.
- Change APR amount
- Change Withdraw Deduction amount.
- Stake Amount event missing.
- Unstake Amount event missing.
- Claim Reward event missing.

### Stake Function

- Insufficient balance check is redundant since activating the `transferFrom` function will revert if the user does not have enough balance.

- Is the staking platform expected to work with a token that handles taxed transfers? Otherwise, the recheck of the amount transferred is unnecessary.

- **Logic Optimization Opportunity**: User can skip pushing an empty stake by creating the Staking object first and then pushing it directly to the array.

### canWithdrawAmount

- The function does not distinguish between the two amounts returned. It is recommended to return a single value or edit the `_canWithdraw` to actually include the amount that can be withdrawn logic.

### earnedToken

- Function can be external since it is never used inside the contract.
- To avoid loss of precision it is recommended to always use `mul` before all `div` operations.

### unstake

- Having multiple stakes would only increase the gas cost of the transaction and the cost would still be increased regardless of the amount of valid stakes. Recommended solution: check `_staking.amount > 0` before calculating any rewards.

- Calculate the rewards in a single variable to save on gas for multiple calculations

### claimEarned

- Check **CRITICAL** for missing reward token balance check.

### getStakedPlans

- Although the function is intended to be used to check if the users have staked in a plan, it does not take into account if the user has already unstaked, where the plan would still be returned.
