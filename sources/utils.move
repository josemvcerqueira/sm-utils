module utils::utils {
    use sui::coin::{Self, Coin};

    #[test_only]
    use sui::test_utils::assert_eq;

    const PRECISION: u128 = 1_000_000;

    public fun handle_coin_vector<X>(
      vector_x: vector<Coin<X>>,
      coin_in_value: u64,
      ctx: &mut TxContext
    ): Coin<X> {
      let mut coin_x = coin::zero<X>(ctx);

      if (vector_x.is_empty()){
        vector_x.destroy_empty();
        return coin_x
      };

      coin_x.join_vec(vector_x);

      let coin_x_value = coin_x.value();
      if (coin_x_value > coin_in_value) coin_x.split_and_transfer(coin_x_value - coin_in_value, ctx.sender(), ctx);

      coin_x
    }

    public fun deduct_slippage(amount: u64, slippage: u64): u64 {
      let (amount, slippage) = ((amount as u128), (slippage as u128));

      let slippage_amount = amount * (slippage * PRECISION) / (100 * 1000 * PRECISION);

      ((amount - slippage_amount) as u64)
    }

    public fun to_result<Object: key + store>(obj: Object): Object {
      obj
    }

    public fun deduct_slippage_from_vector(mut amounts: vector<u64>, slippage: u64): vector<u64> {

      let mut i = 0;
      let len = amounts.length();

      while (len > i) {
        let amount_ref = &mut amounts[i];
        let amount = *amount_ref;

        let (amount, slippage) = ((amount as u128), (slippage as u128));

        let slippage_amount = amount * (slippage * PRECISION) / (100 * 1000 * PRECISION);

        *amount_ref = ((amount - slippage_amount) as u64);

        i = i + 1;
      };

      amounts
   }


   #[test]
   fun test_deduct_slippage() {
    assert_eq(deduct_slippage(100, 10 * 1000), 90);
   }   

   #[test]
   fun test_deduct_slippage_from_vector() {
    let amounts = vector[100, 1000, 10_000];

    assert_eq(deduct_slippage_from_vector(amounts, 10 * 1000), vector[90, 900, 9_000]);
   }    
}