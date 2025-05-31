module TalentMint::store {
    use std::vector;
    use TalentMint::nft::PlatformCap;

    /// NFT Store for holding multiple NFTs
    public struct NFTStore has key, store {
        id: UID,
        owner: address,
        nfts: vector<address>, // Store NFT object IDs
        collections: vector<address>, // Store collection IDs
    }

    /// Events
    public struct StoreCreated has copy, drop {
        store_id: address,
        owner: address,
    }

    public struct NFTAddedToStore has copy, drop {
        store_id: address,
        nft_id: address,
        owner: address,
    }

    public struct CollectionAddedToStore has copy, drop {
        store_id: address,
        collection_id: address,
        owner: address,
    }

    // Error Boundaries
    const E_NOT_OWNER: u64 = 5;

    /// Create a new NFT store
    public entry fun create_store(ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        
        let nft_store = NFTStore {
            id: object::new(ctx),
            owner: sender,
            nfts: vector::empty<address>(),
            collections: vector::empty<address>(),
        };
        
        let store_id = object::uid_to_address(&nft_store.id);
        
        // Emit store creation event
        sui::event::emit(StoreCreated {
            store_id,
            owner: sender,
        });
        
        transfer::transfer(nft_store, sender);
    }

    /// Add NFT to store (by mutable reference/ID)
    public entry fun add_nft_to_store(
        store: &mut NFTStore,
        nft_id: address,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        assert!(store.owner == sender, E_NOT_OWNER);
        
        vector::push_back(&mut store.nfts, nft_id);
        
        let store_id = object::uid_to_address(&store.id);
        sui::event::emit(NFTAddedToStore {
            store_id,
            nft_id,
            owner: sender,
        });
    }

    /// Add collection to store (by mutable reference/ID)
    public entry fun add_collection_to_store(
        store: &mut NFTStore,
        collection_id: address,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        assert!(store.owner == sender, E_NOT_OWNER);
        
        vector::push_back(&mut store.collections, collection_id);
        
        let store_id = object::uid_to_address(&store.id);
        sui::event::emit(CollectionAddedToStore {
            store_id,
            collection_id,
            owner: sender,
        });
    }

    /// Remove NFT from store
    public entry fun remove_nft_from_store(
        store: &mut NFTStore,
        nft_id: address,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        assert!(store.owner == sender, E_NOT_OWNER);
        
        let (found, index) = vector::index_of(&store.nfts, &nft_id);
        if (found) {
            vector::remove(&mut store.nfts, index);
        };
    }

    /// Remove collection from store
    public entry fun remove_collection_from_store(
        store: &mut NFTStore,
        collection_id: address,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        assert!(store.owner == sender, E_NOT_OWNER);
        
        let (found, index) = vector::index_of(&store.collections, &collection_id);
        if (found) {
            vector::remove(&mut store.collections, index);
        };
    }

    /// Platform transfer NFT store (using platform capability)
    public entry fun platform_transfer_store(
        nft_store: NFTStore,
        recipient: address,
        _cap: &PlatformCap,
        _ctx: &mut TxContext
    ) {
        transfer::transfer(nft_store, recipient);
    }

    /// Transfer store ownership
    public entry fun transfer_store(
        store: NFTStore,
        recipient: address,
        ctx: &mut TxContext
    ) {
        assert!(store.owner == tx_context::sender(ctx), E_NOT_OWNER);
        transfer::public_transfer(store, recipient);
    }

    /// Update store owner (for internal tracking after transfer)
    public entry fun update_store_owner(
        store: &mut NFTStore,
        new_owner: address,
        ctx: &mut TxContext
    ) {
        assert!(store.owner == tx_context::sender(ctx), E_NOT_OWNER);
        store.owner = new_owner;
    }

    public fun get_store_nfts(store: &NFTStore): &vector<address> {
        &store.nfts
    }

    public fun get_store_collections(store: &NFTStore): &vector<address> {
        &store.collections
    }

    public fun get_store_owner(store: &NFTStore): address {
        store.owner
    }

    public fun get_store_info(store: &NFTStore): (address, u64, u64) {
        (
            store.owner,
            vector::length(&store.nfts),
            vector::length(&store.collections)
        )
    }

    public fun has_nft(store: &NFTStore, nft_id: address): bool {
        vector::contains(&store.nfts, &nft_id)
    }

    /// Check if collection is in store
    public fun has_collection(store: &NFTStore, collection_id: address): bool {
        vector::contains(&store.collections, &collection_id)
    }

    public fun get_total_items(store: &NFTStore): u64 {
        vector::length(&store.nfts) + vector::length(&store.collections)
    }
}