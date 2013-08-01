module visitor;

import player;
import bloc;

interface IVisitor
{
	void visit(Player entity);
	void visit(BlocImmobile entity);
	void visit(BlocMobileMath entity);
	void visit(BlocFonction entity);
	void visit(BlocCheckpoint entity);
}

interface IVisitable
{
	void accept(IVisitor visitor);	
}