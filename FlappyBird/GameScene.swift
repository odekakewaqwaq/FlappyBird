//
//  GameScene.swift
//  FlappyBird
//
//  Created by 永井 伸枝 on 2016/04/30.
//  Copyright © 2016年 nobue.nagai. All rights reserved.
//

import SpriteKit

class GameScene: SKScene{

    override func didMoveToView(view: SKView){
        //背景色を設定
        backgroundColor = UIColor(colorLiteralRed: 0.15, green:0.75, blue:0.90, alpha: 1)
        
        //スクロールするスプライトの親ノード
        let scrollNode = SKNode() /*let追加したけどいいんかな？*/
        addChild(scrollNode)
        
        //地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        //必要な枚数を計算
        let needNumber = 2.0 + (frame.size.width / groundTexture.size().width)
        
        //スクロールするアクションを作成
        //左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveByX(-groundTexture.size().width , y: 0, duration: 5.0)
        
        //元の位置に戻すアクション
        let resetGround = SKAction.moveByX(groundTexture.size().width, y: 0, duration: 0.0)
        
        //左にスクロール->元の位置->左にスクロールと無限にくりかえるアクション
        let repeatScrollGround = SKAction.repeatActionForever(SKAction.sequence([moveGround, resetGround]))
        
        //groundのスプライトを配置する
        for var i:CGFloat = 0; i < needNumber; ++i {/*あとでなおしたい*/
            let sprite = SKSpriteNode(texture: groundTexture)
            
            sprite.position = CGPoint(x: i * sprite.size.width, y: groundTexture.size().height / 2)
            sprite.runAction(repeatScrollGround)
            scrollNode.addChild(sprite)

        }
    }
}