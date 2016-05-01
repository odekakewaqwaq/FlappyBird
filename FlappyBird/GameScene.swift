//
//  GameScene.swift
//  FlappyBird
//
//  Created by 永井 伸枝 on 2016/04/30.
//  Copyright © 2016年 nobue.nagai. All rights reserved.
//

import SpriteKit

class GameScene: SKScene{
    
    var scrollNode:SKNode!
    var wallNode:SKNode!

    override func didMoveToView(view: SKView){
        //背景色を設定
        backgroundColor = UIColor(colorLiteralRed: 0.15, green:0.75, blue:0.90, alpha: 1)
        
        //スクロールするスプライトの親ノード
        scrollNode = SKNode() /*let追加したけどいいんかな？*/
        addChild(scrollNode)
        
        setupGround()
        setupCloud()
        setupWall()
        }
    
 /*------------------------------------------------------------------------------------------------------------*/
    
    func setupGround(){
    
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
    
 /*------------------------------------------------------------------------------------------------------------*/
    
    func setupCloud(){
        //雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        //必要な枚数を計算
        let needCloudNumber = 2.0 + (frame.size.width / cloudTexture.size().width)
        
        //スクロールするアクションを作成
        //左方向に画像一枚文スクロールさせるアクション
        let moveCloud = SKAction.moveByX(-cloudTexture.size().width , y:0 , duration: 20.0)
        
        //元の位置に戻すアクション
        let resetCloud = SKAction.moveByX(cloudTexture.size().width , y:0 , duration: 0.0)
        
        //左にスクロール->元の位置->左にスクロールと無限にくりかえるアクション
        let repeatScrollCloud = SKAction.repeatActionForever(SKAction.sequence([moveCloud,resetCloud]))
        
        //スプライトを配置する
        for var i:CGFloat = 0; i < needCloudNumber ; ++i{
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100
            
            sprite.position = CGPoint(x: i * sprite.size.width, y: size.height - cloudTexture.size().height / 2)
            
            sprite.runAction(repeatScrollCloud)
            scrollNode.addChild(sprite)
        }

    }
 /*------------------------------------------------------------------------------------------------------------*/
    
    func setupWall(){
        //壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .Linear
        
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width * 2 )
        
        //画面外まで移動するアクションを作成
        let moveWall = SKAction.moveByX(-movingDistance, y: 0, duration:4.0)
        
        //自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        //2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        //壁を生成するアクションを作成
        let createWallAnimation = SKAction.runBlock({
            //壁関連のノードを載せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width * 2, y: 0.0)
            wall.zPosition = -50.0//雲より手前、地面より奥
            //画面のY軸の中央値
            let center_y = self.frame.size.height / 2
            //壁のY座標を上下ランダムにさせる時の最大値
            let random_y_range = self.frame.size.height / 4
            //したの壁のY軸の加減
            let under_wall_lowest_y = UInt32 ( center_y - wallTexture.size().height / 2 - random_y_range / 2 )
            
            //ランダムな値(1~random_y_range)を生成
            let random_y = arc4random_uniform( UInt32(random_y_range) )
            
            //Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_wall_y = CGFloat (under_wall_lowest_y + random_y)
            
            //キャラが通り抜ける隙間の長さ
            let slit_length = self.frame.size.height / 6
            
            //下側の壁を作成
            let under = SKSpriteNode (texture: wallTexture)
            under.position = CGPoint(x: 0.0, y: under_wall_y)
            wall.addChild(under)
            
            //上側の壁を作成
            let upper = SKSpriteNode (texture: wallTexture)
            upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length )
            
            wall.addChild(upper)
            
            wall .runAction(wallAnimation)
            
            self.wallNode.addChild(wall)
        })
        //次の壁作成までの待ち時間のアクションを作成
        let waitAnimation = SKAction.waitForDuration(2)
        
        //壁を作成->待ち時間->壁を無限にくりかえるアクションを作成
        let repeatForeverAnimation = SKAction.repeatActionForever(SKAction.sequence([createWallAnimation , waitAnimation]))
        
        runAction(repeatForeverAnimation)
    }
    
 /*------------------------------------------------------------------------------------------------------------*/
    func setupBird(){
        //鳥の画像を2種類読み込む
        //2種類のてきすちゃを交互に変更するアニメーションを作成
        //スプライトを作成
        //アニメーションを設定
        //スプライトを追加する
    }
}