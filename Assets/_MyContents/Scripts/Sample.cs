using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


namespace MyContents.Samples
{
    public class Sample : MonoBehaviour
    {
        // 生成する要素のベース
        [SerializeField] GameObject _createColumn;
        // 要素の親ノード
        [SerializeField] RectTransform _contentsParent;
        // 生成数
        [SerializeField] int _createNum = 10;

        [Header("Materials")]
        // Imageコンポーネント用マテリアル
        [SerializeField] Material _imageMaterial;
        // Textコンポーネント用マテリアル
        [SerializeField] Material _textMaterial;


        void Start()
        {
            // 値が直接書き換わらないようにインスタンスを生成して設定する
            var imageMatInstance = new Material(this._imageMaterial);
            var textMatInstance = new Material(this._textMaterial);

            var myTrs = (RectTransform)this.transform;
            var pos = myTrs.localPosition;
            var halfSize = myTrs.sizeDelta / 2;

            // フェードの境界をマテリアルに設定
            int materialID_Border = Shader.PropertyToID("_Border");
            var border = new Vector4(
                pos.y + halfSize.y,    // top
                pos.y - halfSize.y,    // bottom
                pos.x + halfSize.x,    // left
                pos.x - halfSize.x);   // right
            imageMatInstance.SetVector(materialID_Border, border);
            textMatInstance.SetVector(materialID_Border, border);

            for(int i = 0; i < this._createNum; ++i)
            {
                var obj = Instantiate<GameObject>(this._createColumn, this._contentsParent);
                obj.SetActive(true);
                obj.GetComponent<Image>().material = imageMatInstance;
                obj.GetComponentInChildren<Text>().material = textMatInstance;
            }
        }
    }
}
