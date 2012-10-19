package a3dparticle.animators.actions.drift
{
	import a3dparticle.animators.actions.PerParticleAction;
	import a3dparticle.core.SubContainer;
	import a3dparticle.particle.ParticleParam;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.passes.MaterialPassBase;
	import away3d.materials.compilation.ShaderRegisterElement;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Vector3D;
	
	import away3d.arcane;
	use namespace arcane;
	/**
	 * ...
	 * @author ...
	 */
	public class DriftLocal extends PerParticleAction
	{
		private var driftAttribute:ShaderRegisterElement;
		
		//return a Vector3D that (Vector3D.x,Vector3D.y,Vector3D.z) is drift position,Vector3D.w is drift cycle
		private var _driftFun:Function;
		
		private var _driftData:Vector3D;
		
		public function DriftLocal(fun:Function=null)
		{
			dataLenght = 4;
			_name = "DriftLocal";
			_driftFun = fun;
		}
		
		override public function genOne(param:ParticleParam):void
		{
			if (_driftFun != null)
			{
				_driftData = _driftFun(param);
			}
			else
			{
				if (!param[_name]) throw new Error("there is no " + _name + " in param!");
				_driftData = param[_name];
			}
		}
		
		override public function distributeOne(index:int, verticeIndex:uint, subContainer:SubContainer):void
		{
			getExtraData(subContainer).push(_driftData.x, _driftData.y, _driftData.z, Math.PI * 2 / _driftData.w);
		}
		
		override public function getAGALVertexCode(pass : MaterialPassBase) : String
		{
			var driftAttribute:ShaderRegisterElement = shaderRegisterCache.getFreeVertexAttribute();
			saveRegisterIndex("driftAttribute", driftAttribute.index);
			var temp:ShaderRegisterElement = shaderRegisterCache.getFreeVertexVectorTemp();
			var dgree:ShaderRegisterElement = new ShaderRegisterElement(temp.regName, temp.index, "x");
			var sin:ShaderRegisterElement = new ShaderRegisterElement(temp.regName, temp.index, "y");
			var cos:ShaderRegisterElement = new ShaderRegisterElement(temp.regName, temp.index, "z");
			shaderRegisterCache.addVertexTempUsages(temp, 1);
			var temp2:ShaderRegisterElement = shaderRegisterCache.getFreeVertexVectorTemp();
			var distance:ShaderRegisterElement = new ShaderRegisterElement(temp2.regName, temp2.index, "xyz");
			shaderRegisterCache.removeVertexTempUsage(temp);
			
			var code:String = "";
			code += "mul " + dgree.toString() + "," + animationRegistersManager.vertexTime.toString() + "," + driftAttribute.toString() + ".w\n";
			code += "sin " + sin.toString() + "," + dgree.toString() + "\n";
			code += "mul " + distance.toString() + "," + sin.toString() + "," + driftAttribute.toString() + ".xyz\n";
			code += "add " + animationRegistersManager.offsetTarget.toString() +"," + distance.toString() + "," + animationRegistersManager.offsetTarget.toString() + "\n";
			
			if (_animation.needVelocity)
			{	code += "cos " + cos.toString() + "," + dgree.toString() + "\n";
				code += "mul " + distance.toString() + "," + cos.toString() + "," + driftAttribute.toString() + ".xyz\n";
				code += "add " + animationRegistersManager.velocityTarget.toString() + ".xyz," + distance.toString() + "," + animationRegistersManager.velocityTarget.toString() + ".xyz\n";
			}
			
			return code;
		}
		
		override public function setRenderState(stage3DProxy : Stage3DProxy, renderable : IRenderable) : void
		{
			stage3DProxy.context3D.setVertexBufferAt(getRegisterIndex("driftAttribute"), getExtraBuffer(stage3DProxy, SubContainer(renderable)), 0, Context3DVertexBufferFormat.FLOAT_4);
		}
	}

}