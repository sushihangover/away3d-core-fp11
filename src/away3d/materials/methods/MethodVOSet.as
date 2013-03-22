package away3d.materials.methods
{
	import away3d.arcane;
	use namespace arcane; // ASX#1001

	public class MethodVOSet
	{
		public var method : EffectMethodBase;
		public var data : MethodVO;

		public function MethodVOSet(method : EffectMethodBase)
		{
			this.method = method;
			data = method.createMethodVO();
		}
	}
}
