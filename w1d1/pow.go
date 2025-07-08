package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"time"
)

// POW 结构体包含 POW 计算所需的基本信息
type POW struct {
	nickname string        // 用户昵称
	nonce    int           // 随机数
	hash     string        // 计算得到的哈希值
	duration time.Duration // 计算耗时
}

// NewPOW 创建一个新的 POW 实例
func NewPOW(nickname string) *POW {
	return &POW{
		nickname: nickname,
		nonce:    0,
	}
}

// Compute 计算满足指定难度(前导零个数)的哈希
func (p *POW) Compute(leadingZeros int) {
	start := time.Now()

	for {
		data := fmt.Sprintf("%s%d", p.nickname, p.nonce)
		hash := sha256.Sum256([]byte(data))
		hashStr := hex.EncodeToString(hash[:])

		// 检查是否满足前导零条件
		if hasLeadingZeros(hashStr, leadingZeros) {
			p.hash = hashStr
			p.duration = time.Since(start)
			break
		}

		p.nonce++
	}
}

// hasLeadingZeros 检查哈希字符串是否以指定数量的0开头
func hasLeadingZeros(hash string, zeros int) bool {
	if zeros <= 0 {
		return true
	}
	if zeros > len(hash) {
		return false
	}
	for _, c := range hash[:zeros] {
		if c != '0' {
			return false
		}
	}
	return true
}

// PrintResult 打印计算结果
func (p *POW) PrintResult(leadingZeros int) {
	fmt.Printf("找到 %d 个前导零的哈希:\n", leadingZeros)
	fmt.Printf("输入内容: %s%d\n", p.nickname, p.nonce)
	fmt.Printf("哈希值: %s\n", p.hash)
	fmt.Printf("耗时: %v\n", p.duration)
	fmt.Println("----------------------------------")
}

func main() {
	nickname := "lumos" // 替换为你的昵称
	pow := NewPOW(nickname)

	// 计算4个前导零的哈希
	pow.Compute(4)
	pow.PrintResult(4)

	// 重置 nonce 以计算5个前导零的哈希
	pow.nonce = 0
	pow.Compute(5)
	pow.PrintResult(5)
}
