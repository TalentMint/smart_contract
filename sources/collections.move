module TalentMint::collection {
    use std::string::{Self, String, utf8};
    use sui::event;

    /// NFT Collection struct that holds collection metadata
    public struct NFTCollection has key, store {
        id: UID,
        creator: address,
        name: String,
        description: String,
        category: String,
        platform: String,
        total_supply: u64,
        max_supply: u64, // 0 means unlimited
    }

    /// Event for collection creation
    public struct CollectionCreated has copy, drop {
        collection_id: address,
        creator: address,
        name: String,
        category: String,
        max_supply: u64,
    }

    // Error codes
    const E_MAX_SUPPLY_REACHED: u64 = 2;
    const E_NOT_CREATOR: u64 = 3;

    /// Create a new NFT collection
    public entry fun create_collection(
        name: vector<u8>,
        description: vector<u8>,
        category: vector<u8>,
        max_supply: u64, // 0 for unlimited
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        
        let collection = NFTCollection {
            id: object::new(ctx),
            creator: sender,
            name: string::utf8(name),
            description: string::utf8(description),
            category: string::utf8(category),
            platform: utf8(b"TALENTMINT"),
            total_supply: 0,
            max_supply,
        };

        let collection_id = object::uid_to_address(&collection.id);

        // Emit collection creation event
        event::emit(CollectionCreated {
            collection_id,
            creator: sender,
            name: collection.name,
            category: collection.category,
            max_supply,
        });

        // Transfer collection to creator
        transfer::public_transfer(collection, sender);
    }

    /// Update collection description (only creator)
    public entry fun update_collection_description(
        collection: &mut NFTCollection,
        new_description: vector<u8>,
        ctx: &mut TxContext
    ) {
        assert!(collection.creator == tx_context::sender(ctx), E_NOT_CREATOR);
        collection.description = string::utf8(new_description);
    }

    /// Increment supply (called by minting module)
    public fun increment_supply(collection: &mut NFTCollection): u64 {
        // Check max supply if set
        if (collection.max_supply > 0) {
            assert!(collection.total_supply < collection.max_supply, E_MAX_SUPPLY_REACHED);
        };

        collection.total_supply = collection.total_supply + 1;
        collection.total_supply
    }

    /// Get collection info
    public fun get_collection_info(collection: &NFTCollection): (String, String, String, address, u64, u64) {
        (
            collection.name,
            collection.description,
            collection.category,
            collection.creator,
            collection.total_supply,
            collection.max_supply
        )
    }

    /// Get collection creator
    public fun get_creator(collection: &NFTCollection): address {
        collection.creator
    }

    /// Get collection ID
    public fun get_collection_id(collection: &NFTCollection): address {
        object::uid_to_address(&collection.id)
    }

    /// Get collection category
    public fun get_category(collection: &NFTCollection): String {
        collection.category
    }

    /// Get total supply
    public fun get_total_supply(collection: &NFTCollection): u64 {
        collection.total_supply
    }

    /// Get max supply
    public fun get_max_supply(collection: &NFTCollection): u64 {
        collection.max_supply
    }
}