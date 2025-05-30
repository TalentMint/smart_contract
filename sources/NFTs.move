module TalentMint::NFTs {
    // use sui::object::{Self, UID};
    // use sui::tx_context::{TxContext};
    // use sui::url::Url;
    // use std::string::String;
    // use std::option::Option;
    use std::string::String;
    
    public struct NFT has copy, drop, store {
        creator: address,
        name: String,
        description: String,
        image: vector<u8>,
        category: String,
        value: u64,
        unlocked: bool,
        transferable: bool,
    }

    public struct NFTStore has key, store {
        id: UID,
        owner: address,
        categories: vector<NFT>
    }

    // Error Boundaries
    const E_NOT_TRANSFERABLE: u64 = 0;

    fun init(ctx: &mut TxContext) {
        let nft_store = NFTStore {
            id: object::new(ctx),
            owner: tx_context::sender(ctx),
            categories: vector::empty<NFT>(),
        };
        transfer::transfer(nft_store, tx_context::sender(ctx));
    }

    public entry fun create_nft(
        store: &mut NFTStore,
        name: String,
        description: String,
        image: vector<u8>,
        category: String,
        value: u64,
        unlocked: bool,
        transferable: bool,
        ctx: &mut TxContext
    ) {
        let nft = NFT {
            creator: tx_context::sender(ctx),
            name: name,
            description: description,
            image: image,
            category: category,
            value: value,
            unlocked: false,
            transferable: true,
        };
        vector::push_back(&mut store.categories, nft)
    }

    public fun get_nfts(list: &NFTStore): &vector<NFT> {
        &list.categories
    }

    public fun unlock_nft(nft: &mut NFT) {
        nft.unlocked = true;
    }

    public fun transfer_nft(nft: &mut NFT) {
        nft.transferable = true;
    }

    public fun is_transferable(nft: &NFT): bool {
        nft.transferable && nft.unlocked
    }

    // public entry fun safe_transfer_nft(
    //     nft: &mut NFTStore,
    //     recipient: address,
    // ) {
    //     assert!(nft.transferable && nft.unlocked, E_NOT_TRANSFERABLE);
    //     transfer::public_transfer(nft, recipient);
    // }
}