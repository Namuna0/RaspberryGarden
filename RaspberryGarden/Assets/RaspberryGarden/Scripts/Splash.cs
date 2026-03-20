using UnityEngine;
using UnityEngine.UI;
using UnityEngine.UIElements.Experimental;

namespace RaspberryGarden
{
    public class BackGround : MonoBehaviour
    {
        [SerializeField] private Image _addCircle;

        private float _timer;

        private readonly Color White = new Color(0, 0, 0, 1);

        private void Update()
        {

         //   _timer += Time.deltaTime;
        }
    }
}
