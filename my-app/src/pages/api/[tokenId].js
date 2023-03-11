//creating API route for OpenSea to access metadata of our NFTs
export default function handler(req, res) {
    //getting the tokenId from query param
    const tokenId = req.query.tokenId;

    //as images are uploaded on github, we can extract them directly
    const image_url = "https://raw.githubusercontent.com/LearnWeb3DAO/NFT-Collection/main/my-app/public/cryptodevs/";

    //the api sends back the metadata for cryptodev
    //Opensea has some metadata standards
    res.status(200).json({
        name: "Crypto Dev #" + tokenId,
        description: "Crypto Dev is a collection of developers in crypto",
        image: image_url + tokenId + ".svg",
    });
}