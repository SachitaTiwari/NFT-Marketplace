// ================================
// hardhat.config.js
// ================================

require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {
      chainId: 1337
    },
    core_testnet2: {
      url: "https://rpc.test2.btcs.network",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 1115,
      gasPrice: 20000000000,
      gas: 6000000,
      timeout: 60000
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 1337
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 40000
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD"
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  }
};

// ================================
// scripts/deploy.js
// ================================

const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 Starting NFT Marketplace deployment...\n");

  // Get the ContractFactory and Signers
  const [deployer] = await ethers.getSigners();

  console.log("📝 Deployment Details:");
  console.log("==========================================");
  console.log("Deploying contracts with account:", deployer.address);
  console.log("Account balance:", ethers.utils.formatEther(await deployer.getBalance()), "CORE");
  console.log("Network:", network.name);
  console.log("Chain ID:", network.config.chainId || "Unknown");
  console.log("==========================================\n");

  try {
    // Deploy the Project contract (NFT Marketplace)
    console.log("📦 Deploying Project contract...");
    const ProjectContract = await ethers.getContractFactory("Project");
    
    const project = await ProjectContract.deploy();
    console.log("⏳ Waiting for deployment confirmation...");
    
    await project.deployed();

    console.log("✅ Project contract deployed successfully!");
    console.log("==========================================");
    console.log("📍 Contract Address:", project.address);
    console.log("🔗 Transaction Hash:", project.deployTransaction.hash);
    console.log("⛽ Gas Used:", project.deployTransaction.gasLimit?.toString() || 'N/A');
    console.log("==========================================\n");
    
    // Get and display contract details
    console.log("📊 Contract Information:");
    console.log("==========================================");
    const listingPrice = await project.getListingPrice();
    const totalNFTs = await project.getTotalNFTs();
    const soldNFTs = await project.getSoldNFTs();
    
    console.log("💰 Listing Price:", ethers.utils.formatEther(listingPrice), "CORE");
    console.log("📈 Total NFTs:", totalNFTs.toString());
    console.log("💎 Sold NFTs:", soldNFTs.toString());
    console.log("👤 Contract Owner:", await project.owner());
    console.log("==========================================\n");

    // Verification instructions
    console.log("🔍 Contract Verification:");
    console.log("==========================================");
    console.log("To verify your contract, run:");
    console.log(`npx hardhat verify --network ${network.name} ${project.address}`);
    console.log("==========================================\n");

    // Save deployment info
    const deploymentInfo = {
      network: network.name,
      chainId: network.config.chainId,
      contractAddress: project.address,
      transactionHash: project.deployTransaction.hash,
      deployer: deployer.address,
      listingPrice: ethers.utils.formatEther(listingPrice),
      deploymentTime: new Date().toISOString()
    };

    console.log("📁 Deployment Summary:");
    console.log("==========================================");
    console.log(JSON.stringify(deploymentInfo, null, 2));
    console.log("==========================================");

    console.log("\n🎉 Deployment completed successfully!");
    console.log("Your NFT Marketplace is ready to use!");

  } catch (error) {
    console.error("❌ Deployment failed:");
    console.error(error);
    process.exit(1);
  }
}

// Handle errors
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("💥 Unexpected error:");
    console.error(error);
    process.exit(1);
  });

// ================================
// .env (Template)
// ================================

# IMPORTANT: Never commit this file to version control
# Add your actual values and keep this file secure

# Private Key (without 0x prefix)
# Get this from your wallet (MetaMask, etc.)
PRIVATE_KEY=your_private_key_here

# Optional: API Key for contract verification
ETHERSCAN_API_KEY=your_etherscan_api_key_here

# Optional: Enable gas reporting
REPORT_GAS=true

# Optional: RPC URLs for other networks
MAINNET_RPC_URL=https://rpc.ankr.com/core
POLYGON_RPC_URL=https://polygon-rpc.com

# Optional: Project settings
PROJECT_NAME=NFT Marketplace
PROJECT_VERSION=1.0.0

// ================================
// .gitignore
// ================================

# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Hardhat files
cache/
artifacts/
typechain/
typechain-types/

# Coverage reports
coverage/
coverage.json
.nyc_output/

# IDE and editor files
.vscode/
.idea/
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Logs
logs/
*.log

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Compiled binary addons
build/Release/

# Dependency directories
jspm_packages/

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# parcel-bundler cache
.cache
.parcel-cache

# next.js build output
.next

# nuxt.js build output
.nuxt

# vuepress build output
.vuepress/dist

# Serverless directories
.serverless

# FuseBox cache
.fusebox/

# DynamoDB Local files
.dynamodb/

# TernJS port file
.tern-port

# Package files
*.tar.gz
*.zip

# Test files
test-results/
playwright-report/
