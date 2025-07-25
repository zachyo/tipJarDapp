# CreatorVault 🎨💰

**A Next-Generation Decentralized Creator Economy Platform on Stacks**

CreatorVault transforms the traditional tip jar concept into a comprehensive creator economy platform, enabling content creators to monetize their work through tips, subscriptions, and community engagement—all powered by Stacks blockchain and Clarity smart contracts.

![Stacks](https://img.shields.io/badge/Stacks-Blockchain-orange)
![Clarity](https://img.shields.io/badge/Clarity-v3.0-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Phase%201%20Complete-brightgreen)

## 🌟 Vision

CreatorVault aims to build the infrastructure for a decentralized creator economy where:
- Creators maintain full ownership of their earnings
- Fans can support creators directly without intermediaries
- Community engagement drives value creation
- Cross-creator collaboration is seamlessly enabled

## ✨ Features

### 🚀 Phase 1: Core Infrastructure ✅ **COMPLETE**

- **Creator Registration**: Comprehensive profiles with bio, social links, and verification system
- **Direct Tipping**: Send STX tips with optional messages to any registered creator
- **Smart Balance Management**: Tips accumulate in creator's vault for flexible withdrawal
- **Platform Sustainability**: Configurable platform fee (1.5% default) for ecosystem growth
- **Complete Tip History**: Every transaction recorded with timestamps and messages
- **Enhanced Security**: Emergency pause functionality and robust access controls
- **Analytics Foundation**: Creator stats, platform metrics, and engagement tracking

### 🔮 Upcoming Features

#### 📅 Phase 2: Multi-Token Integration
- **Multi-Asset Support**: Accept STX, USDA, sBTC, and other SIP-010 tokens
- **Automatic Conversion**: Smart token swapping for creator preferences
- **Dynamic Fee Calculation**: Token-specific fee structures

#### 📅 Phase 3: Advanced Creator Tools
- **Subscription System**: Recurring monthly/weekly support
- **Milestone Funding**: Goal-based campaign creation
- **NFT Rewards**: Auto-mint supporter NFTs based on tip tiers
- **Streaming Tips**: Real-time payment for content consumption

#### 📅 Phase 4: Social & Collaboration
- **Creator Collaboration**: Shared vaults and revenue splitting
- **Community Governance**: Platform feature voting
- **Cross-Platform Integration**: API for dApp ecosystem

## 🏗️ Architecture

### Smart Contract Structure

```
contracts/
├── creator-vault-core.clar      # Main platform contract (Phase 1)
├── multi-token-support.clar     # SIP-010 integration (Phase 2)
├── subscription-manager.clar    # Recurring payments (Phase 3)
├── nft-rewards.clar            # Dynamic NFT system (Phase 3)
└── governance.clar             # Community voting (Phase 4)
```

### Core Components

- **Creator Registry**: Decentralized creator profile management
- **Tip Engine**: Secure, fee-efficient tipping mechanism
- **Balance Vault**: Creator-controlled fund management
- **Analytics Engine**: On-chain metrics and insights
- **Fee Manager**: Transparent, configurable platform economics

## 🚀 Quick Start

### Prerequisites

- [Clarinet](https://docs.hiro.so/clarinet) for local development
- [Stacks CLI](https://docs.stacks.co/build-apps/references/stacks-cli) for deployment
- Stacks wallet for interaction

### Installation

```bash
# Clone the repository
git clone https://github.com/yourname/creator-vault.git
cd creator-vault

# Install Clarinet (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf https://hirosystems.github.io/clarinet/install.sh | sh

# Initialize the project
clarinet new creator-vault
cd creator-vault

# Add the contract
# Copy the creator-vault-core.clar into contracts/ directory
```

### Local Development

```bash
# Check contract syntax
clarinet check

# Run tests
clarinet test

# Start local development environment
clarinet console
```

### Deployment

```bash
# Deploy to testnet
clarinet deploy --testnet

# Deploy to mainnet
clarinet deploy --mainnet
```

## 📖 Usage Guide

### For Creators

#### 1. Register as a Creator
```clarity
(contract-call? .creator-vault-core register-creator 
  "Creator Name" 
  "Brief bio about your work and content" 
  (list "https://twitter.com/creator" "https://website.com"))
```

#### 2. Update Your Profile
```clarity
(contract-call? .creator-vault-core update-creator-profile 
  "Updated Name" 
  "New bio with latest information" 
  (list "https://newlink.com"))
```

#### 3. Withdraw Your Tips
```clarity
(contract-call? .creator-vault-core withdraw-funds u1000000) ;; 1 STX
```

### For Supporters

#### Send a Tip
```clarity
(contract-call? .creator-vault-core tip-creator 
  'ST1CREATOR... 
  u500000 ;; 0.5 STX
  (some "Great content! Keep it up!"))
```

#### Check Creator Info
```clarity
(contract-call? .creator-vault-core get-creator-info 'ST1CREATOR...)
```

## 🔧 Contract API

### Core Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| `register-creator` | Register as a new creator | name, bio, links |
| `update-creator-profile` | Update creator information | name, bio, links |
| `tip-creator` | Send STX tip to creator | recipient, amount, message |
| `withdraw-funds` | Withdraw accumulated tips | amount |

### Read-Only Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `get-creator-info` | Get creator profile data | Creator details |
| `get-creator-balance` | Get creator's available balance | Balance amount |
| `get-tip-info` | Get specific tip details | Tip information |
| `get-tip-stats` | Get platform statistics | Volume, tips, creators |

## 🛡️ Security Features

- **Access Control**: Role-based permissions for admin functions
- **Emergency Pause**: Circuit breaker for security incidents  
- **Input Validation**: Comprehensive parameter checking
- **Overflow Protection**: Safe arithmetic operations
- **Reentrancy Guards**: Protection against recursive attacks

## 🧪 Testing

```bash
# Run all tests
clarinet test

# Run specific test
clarinet test tests/creator_registration_test.ts

# Test coverage
clarinet test --coverage
```

## 📊 Platform Economics

- **Platform Fee**: 1.5% (configurable)
- **Minimum Tip**: 0.000001 STX
- **Creator Verification**: Future staking requirement
- **Gas Optimization**: Efficient contract design for low fees

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md).

### Development Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🏆 Why CreatorVault?

### For Creators
- **Own Your Audience**: Direct relationships without platform lock-in
- **Transparent Economics**: Clear fee structure and instant payments
- **Flexible Monetization**: Multiple revenue streams in one platform
- **Community Building**: Tools for deeper fan engagement

### For Supporters  
- **Direct Impact**: Your support goes directly to creators
- **Exclusive Access**: NFT rewards and special content
- **Transparent Transactions**: All activity on-chain and verifiable
- **Cross-Creator Discovery**: Find new creators to support

### For Developers
- **Open Source**: Build on our foundation
- **Extensible Architecture**: Easy integration and customization
- **Stacks Ecosystem**: Leverage Bitcoin security and finality
- **Clear APIs**: Well-documented interfaces

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- **Documentation**: [docs.creatorvault.com](https://docs.creatorvault.com)
- **Website**: [creatorvault.com](https://creatorvault.com)
- **Twitter**: [@CreatorVault](https://twitter.com/creatorvault)
- **Discord**: [Join our community](https://discord.gg/creatorvault)
- **Stacks Explorer**: [View on Explorer](https://explorer.stacks.co)

## 🙏 Acknowledgments

- [Stacks Foundation](https://stacks.org) for the incredible blockchain infrastructure
- [Hiro](https://hiro.so) for development tools and support
- The creator economy pioneers who inspired this project
- Our community of early contributors and supporters

---

**Built with ❤️ on Stacks | Empowering Creators Worldwide**