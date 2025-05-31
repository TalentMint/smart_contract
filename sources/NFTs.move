// module TalentMint::NFTs {
//     use std::string::{String, utf8};
    
//     public struct NFT has copy, drop, store {
//         creator: address,
//         name: String,
//         description: String,
//         image: vector<u8>,
//         category: String,
//         value: u64,
//         unlocked: bool,
//         transferable: bool,
//         platform: String
//     }

//     public struct NFTStore has key, store {
//         id: UID,
//         owner: address,
//         categories: vector<NFT>
//     }

//     // struct PlatformCap has key {

//     // }

//     // Error Boundaries
//     // const E_NOT_TRANSFERABLE: u64 = 0;

//     fun init(ctx: &mut TxContext) {
//         let nft_store = NFTStore {
//             id: object::new(ctx),
//             owner: tx_context::sender(ctx),
//             categories: vector::empty<NFT>(),
//         };
//         transfer::transfer(nft_store, tx_context::sender(ctx));
//     }

//     public entry fun create_nft(
//         store: &mut NFTStore,
//         name: String,
//         description: String,
//         image: vector<u8>,
//         category: String,
//         value: u64,
//         unlocked: bool,
//         transferable: bool,
//         ctx: &mut TxContext
//     ) {
//         let nft = NFT {
//             creator: tx_context::sender(ctx),
//             name: name,
//             description: description,
//             image: image,
//             category: category,
//             value: value,
//             unlocked: unlocked,
//             transferable: transferable,
//             platform: utf8(b"TALENTMINT")
//         };

//         let collection_id = object::uid_to_address(&collection.id);

//         // Emit collection creation event
//         event::emit(CollectionCreated {
//             collection_id,
//             creator: sender,
//             name: collection.name,
//             max_supply,
//         });
        
//         vector::push_back(&mut store.categories, nft)
//     }

//     public fun get_nfts(list: &NFTStore): &vector<NFT> {
//         &list.categories
//     }

//     public fun platform_transfer(
//         nft_store: &mut NFTStore,
//         recipient: address,
//         // cap: &PlatformCap
//     ) {
//         // Only callable if you pass the cap — which only the platform has
//         transfer::transfer(nft_store, recipient);
//     }

//     public fun unlock_nft(nft: &mut NFT) {
//         nft.unlocked = true;
//     }

//     public fun transfer_nft(nft: &mut NFT) {
//         nft.transferable = true;
//     }

//     public fun is_transferable(nft: &NFT): bool {
//         nft.transferable
//     }

//     // public entry fun safe_transfer_nft(
//     //     nft: &mut NFTStore,
//     //     recipient: address,
//     // ) {
//     //     assert!(nft.transferable && nft.unlocked, E_NOT_TRANSFERABLE);
//     //     transfer::public_transfer(nft, recipient);
//     // }
// }