package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"strconv"
	"strings"
	"time"
)

// 区块的结构
type Block struct {
	Index        int
	Timestamp    int64
	Transactions []string
	Hash         string
	PrevHash     string
	Difficulty   int
	Nonce        string
}

type BlockChain []Block

// 计算区块的哈希
func calcHash(block Block) string {
	//Index + Timestamp + PrevHash + Transactions + Nonce
	data := strconv.Itoa(block.Index) + string(block.Timestamp) + block.PrevHash + fmt.Sprintf("%v", block.Transactions) + block.Nonce
	hash := sha256.New()
	hash.Write([]byte(data))
	hashed := hash.Sum(nil)
	return hex.EncodeToString(hashed)
}

// 验证hash值是否正确
func isHashValid(hashed string, difficulty int) bool {
	prefix := strings.Repeat("0", difficulty)
	if strings.HasPrefix(hashed, prefix) {
		return true
	} else {
		return false
	}
}

// 挖矿,产出新的区块
func mineBlock(difficulty int, prevBlock Block, transactions []string) Block {
	block := Block{}
	block.Index = prevBlock.Index + 1
	block.PrevHash = prevBlock.Hash
	block.Difficulty = difficulty
	block.Transactions = transactions
	block.Timestamp = time.Now().Unix()
	block.Nonce = ""

	for i := 0; ; i++ {
		block.Nonce = fmt.Sprintf("%x", i)
		hashed := calcHash(block)
		if isHashValid(hashed, difficulty) {
			block.Hash = hashed
			break
		}
	}
	return block
}

// 其他节点验证区块链是否正确
func isBlockchainValid(blockchain BlockChain) bool {
	for i := 1; i < len(blockchain); i++ {
		curblock := blockchain[i]
		prevblock := blockchain[i-1]
		if curblock.Hash != calcHash(curblock) {
			return false
		}
		if prevblock.Hash != curblock.PrevHash {
			return false
		}
	}
	return true
}

// 打印区块信息
func printBlockchain(block Block) {
	fmt.Printf("Index:%d\nTimestamp:%d\nTransactions:%s\nPrevHash:%s\nHash:%s\n\n", block.Index, block.Timestamp, block.Transactions, block.PrevHash, block.Hash)
}

func main() {
	//初始化难度
	difficulty := 4

	blockchain := BlockChain{}
	//创世块
	genesisBlock := Block{0, time.Now().Unix(), []string{"this is genesisBlock"}, "", "0", difficulty, "0"}
	genesisBlock.Hash = calcHash(genesisBlock)
	printBlockchain(genesisBlock)
	//加入到链
	blockchain = append(blockchain, genesisBlock)

	prevBlock := Block{}
	for i := 1; ; i++ {
		if i == 1 {
			prevBlock = genesisBlock
		}
		//挖矿
		newBlock := mineBlock(difficulty, prevBlock, []string{fmt.Sprintf("a send %dBTC to b", i)})
		blockchain = append(blockchain, newBlock)

		//验证区块链
		if isBlockchainValid(blockchain) {
			printBlockchain(newBlock)
		} else {
			fmt.Println("blockchain is unvalid")
		}
		prevBlock = newBlock
	}
}
