module workshop_project::bank{

    //import sui coin
    use sui::coin;
    //import the account module from the source folder
    use workshop_project::account_move::{
        Account,
        AccountCap,
        new,
        get_owner,
        get_balance_valuation,
        get_balance_part,
        add_balance
    };
    //import the manager module from the source folder
    use workshop_project::manager::{
        Self, 
        BankManagerCap
    };
    //import sui balance
    use sui::balance;
    //import sui table
    use sui::table;

    //Error code initialisation
    const EAccountNotFound: u64 = 100;
    const EAmountExceedsBalance: u64 = 101;
    const EUserAccountNotFound: u64 = 102;
    
    public struct Bank has key, store {
        id: UID,
        accounts: table::Table<address, Account>,
        value: u64,
    }
    //ctx: transaction content
    fun init(ctx: &mut TxContext) {
        let bank_managet_cap = manager::create(ctx);
        transfer::public_transfer(bank_manager_cap, ctx.sender());
        let bank = Bank {
            id: object::new(ctx),
            accounts: table::new<address, Acoount>(ctx),
            value: 0
        };
        transfer::share_object(bank);
    }

    public fun create_account(
            _: &BankManagerCap,
            bank: &mut Bank,
            id: u64, 
            owner: address,
            ctx: &mut TxContext
        ){
        let (account, accountCap) = new(owner, ctx);
        bank.accounts.add(owner, account);
    
        vector::public_transfer(accountCap, owner);
    }

    public fun deposit(
        _: &AccountCap,
        bank: &mut Bank,
        coin: coin::Coin<sui::sui::SUI>,
        ctx: &mut TxContext
    ){
        bank.accounts[ctx.sender()].add_balance(coin.into_balance());
    }

    public fun withdraw(
        _: &AccountCap,
        bank: &mut Bank,
        amount: u64,
        ctx: &mut TxContext
    ){
        assert!(bank.accounts[ctx.sender()].get_balance_valuation() >= ammount, EAmountExceedsBalance);
        let amount_to_be_withdrawn = bank.accounts[ctx.sender()].get_balance_part(amount);
        transfer::public_transfer(
            coin::from_balance(amount_to_be_withdrawn, ctx),
            ctx.sender()
        )
    }

    public fun transfer(
        _: &AccountCap,
        bank: &mut Bank,
        amount: u64,
        reciepient: address,
        ctx: &mut TxContext
    ){
        if(!bank.accounts.contains(reciepient)){
            abort EUserAccountNotFound;
        }
        let balance_to_send = bank.accounts[ctx.sender()].ge6t_balance_part(amount);
        bank.accounts[reciepient].add_balance(balance_to_send);
    }
}