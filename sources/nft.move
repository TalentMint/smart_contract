module TalentMint::nft {
    use std::string::{Self, String, utf8};
    use sui::event;
    use TalentMint::collection::{Self, NFTCollection};

    /// Individual NFT struct
    public struct NFT has key, store {
        id: UID,
        creator: address,
        name: String,
        description: String,
        image: vector<u8>,
        category: String,
        value: u64,
        unlocked: bool,
        transferable: bool,
        platform: String,
        collection_id: address,
        token_id: u64,
    }

    /// Platform capability for administrative functions
    public struct PlatformCap has key, store {
        id: UID,
    }

    /// Events
    public struct NFTMinted has copy, drop {
        nft_id: address,
        collection_id: address,
        token_id: u64,
        creator: address,
        recipient: address,
        name: String,
        category: String,
        value: u64,
    }

    public struct NFTUnlocked has copy, drop {
        nft_id: address,
        owner: address,
    }

    public struct NFTTransferEnabled has copy, drop {
        nft_id: address,
        owner: address,
    }

    // Error codes
    const E_NOT_TRANSFERABLE: u64 = 0;
    const E_NOT_UNLOCKED: u64 = 1;
    const E_NOT_CREATOR: u64 = 3;
    const E_NOT_OWNER: u64 = 5;

    /// Initialize - create platform capability
    fun init(ctx: &mut TxContext) {
        let platform_cap = PlatformCap {
            id: object::new(ctx),
        };
        transfer::transfer(platform_cap, tx_context::sender(ctx));
    }

    /// Mint an NFT from an existing collection
    public entry fun mint_nft(
        collection: &mut NFTCollection,
        name: vector<u8>,
        description: vector<u8>,
        image: vector<u8>,
        value: u64,
        unlocked: bool,
        transferable: bool,
        recipient: address,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        
        // Only collection creator can mint
        assert!(collection::get_creator(collection) == sender, E_NOT_CREATOR);
        
        // Increment supply and get token ID
        let token_id = collection::increment_supply(collection);
        let collection_id = collection::get_collection_id(collection);

        // Create the NFT
        let nft = NFT {
            id: object::new(ctx),
            creator: sender,
            name: string::utf8(name),
            description: string::utf8(description),
            image,
            category: collection::get_category(collection),
            value,
            unlocked,
            transferable,
            platform: utf8(b"TALENTMINT"),
            collection_id,
            token_id,
        };

        let nft_id = object::uid_to_address(&nft.id);

        // Emit minting event
        event::emit(NFTMinted {
            nft_id,
            collection_id,
            token_id,
            creator: sender,
            recipient,
            name: nft.name,
            category: nft.category,
            value,
        });

        // Transfer NFT to recipient
        transfer::public_transfer(nft, recipient);
    }

    /// Mint to sender (convenience function)
    public entry fun mint_to_sender(
        collection: &mut NFTCollection,
        name: vector<u8>,
        description: vector<u8>,
        image: vector<u8>,
        value: u64,
        unlocked: bool,
        transferable: bool,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        mint_nft(collection, name, description, image, value, unlocked, transferable, sender, ctx);
    }

    /// Unlock an NFT (only creator can unlock)
    public entry fun unlock_nft(
        nft: &mut NFT,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        assert!(nft.creator == sender, E_NOT_CREATOR);
        
        nft.unlocked = true;
        
        let nft_id = object::uid_to_address(&nft.id);
        event::emit(NFTUnlocked {
            nft_id,
            owner: sender,
        });
    }

    /// Enable NFT transferability (only creator)
    public entry fun enable_transfer(
        nft: &mut NFT,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        assert!(nft.creator == sender, E_NOT_CREATOR);
        
        nft.transferable = true;
        
        let nft_id = object::uid_to_address(&nft.id);
        event::emit(NFTTransferEnabled {
            nft_id,
            owner: sender,
        });
    }

    /// Platform unlock (using platform capability)
    public entry fun platform_unlock(
        nft: &mut NFT,
        _cap: &PlatformCap,
        _ctx: &mut TxContext
    ) {
        nft.unlocked = true;
        
        let nft_id = object::uid_to_address(&nft.id);
        event::emit(NFTUnlocked {
            nft_id,
            owner: nft.creator,
        });
    }

    /// Platform enable transfer (using platform capability)
    public entry fun platform_enable_transfer(
        nft: &mut NFT,
        _cap: &PlatformCap,
        _ctx: &mut TxContext
    ) {
        nft.transferable = true;
        
        let nft_id = object::uid_to_address(&nft.id);
        event::emit(NFTTransferEnabled {
            nft_id,
            owner: nft.creator,
        });
    }

    /// Safe transfer NFT (checks if transferable and unlocked)
    public entry fun safe_transfer_nft(
        nft: NFT,
        recipient: address,
        _ctx: &mut TxContext
    ) {
        assert!(nft.transferable, E_NOT_TRANSFERABLE);
        assert!(nft.unlocked, E_NOT_UNLOCKED);
        transfer::public_transfer(nft, recipient);
    }

    /// Update NFT description (only creator)
    public entry fun update_nft_description(
        nft: &mut NFT,
        new_description: vector<u8>,
        ctx: &mut TxContext
    ) {
        assert!(nft.creator == tx_context::sender(ctx), E_NOT_CREATOR);
        nft.description = string::utf8(new_description);
    }

    /// Burn an NFT
    public entry fun burn_nft(nft: NFT, _ctx: &mut TxContext) {
        let NFT { 
            id, 
            creator: _, 
            name: _, 
            description: _, 
            image: _, 
            category: _,
            value: _,
            unlocked: _,
            transferable: _,
            platform: _,
            collection_id: _, 
            token_id: _,
        } = nft;
        object::delete(id);
    }

    // === View Functions ===

    /// Get NFT details
    public fun get_nft_info(nft: &NFT): (String, String, String, u64, bool, bool, address, u64) {
        (
            nft.name,
            nft.description,
            nft.category,
            nft.value,
            nft.unlocked,
            nft.transferable,
            nft.collection_id,
            nft.token_id
        )
    }

    /// Check if NFT is transferable
    public fun is_transferable(nft: &NFT): bool {
        nft.transferable && nft.unlocked
    }

    /// Get NFT value
    public fun get_nft_value(nft: &NFT): u64 {
        nft.value
    }

    /// Check if NFT is unlocked
    public fun is_unlocked(nft: &NFT): bool {
        nft.unlocked
    }

    /// Get NFT creator
    public fun get_creator(nft: &NFT): address {
        nft.creator
    }

    /// Get token ID
    public fun get_token_id(nft: &NFT): u64 {
        nft.token_id
    }
}